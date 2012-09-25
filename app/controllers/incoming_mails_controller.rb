require 'application_helper'
require 'openssl'
require "base64"

class IncomingMailsController < ApplicationController
  EMAIL_KEY = "\x1E\x00?\xC2q\\\xA13|G\x19\xD2\xB3\xC0\x97h"
  require 'mail'
  skip_before_filter :verify_authenticity_token, :authorize
  skip_authorization_check

  def create  # need the name 'create' to conform with REST defaults, or change routes
#puts "IncomingController create: params=#{params}"
    @from_address = params['from']
    @possible_senders = Member.find_by_email(@from_address)
#puts "**** Contacts=#{Contact.all.each {|c| c.email_1}.join(' ')}"
#puts "**** @possible_senders=#{@possible_senders}"
    @from_member = login_allowed(@from_address)
# puts "**** @from_member=#{@from_member}"
    unless @from_member
      render :text => I18n.t('Refused unknown sender'), :status => 403, :content_type => Mime::TEXT.to_s
      return
    end
    @privileges = @from_member.role
    @subject = params['subject']
    @body = params['plain']
    AppLog.create(:code => 'Message.create', :description => "Email from #{@from_address}, body = #{@body[0..99]}")
    process_message_response
    @commands = extract_commands(@body)
    if @commands.nil? || @commands.empty?
      Notifier.send_generic(@from_address, I18n.t('error_msg.nothing_in_message', :body => @body[0..160])).deliver
      success = false
    else
      success = process_commands
    end

    # if the message was handled successfully then send a status of 200,
    #   else give a 422 with the errors
    if success
      render :text => I18n.t(:success), :status => 200, :content_type => Mime::TEXT.to_s
    else
      render :text => I18n.t('error_msg.email_commands_not_recogized'), :status => 422, :content_type => Mime::TEXT.to_s
    end
  end # create
  
  # Is this email confirming the receipt of a message (with possible response included?)
  def process_message_response
    # Is this email confirming receipt of a previous message? 
    msg_id = find_message_id_tag(:subject=>@subject, :body=>@body)
#puts "**** body=#{@body}, msg_id=#{msg_id}"
    if msg_id  
      # Does the "confirmed message" id actually match a message?
      message = Message.find_by_id(msg_id)
      if message
        msg_tag = message_id_tag(:id => msg_id, :action => :confirm_tag) # e.g. !2104
        search_target = Regexp.new('[\'\s\(\[]*' + "#{Regexp.escape(msg_tag)}" + '[\'\s\.,\)\]]*')
        # The main reason to strip out the tag (like !2104) from the message is that it may be the
        # first part of the response, if there is one; e.g. "!2104 Kafanchan" replying to a message
        # requesting location. 
        user_reply = first_nonblank_line(@body)
#puts "**** user_reply='#{user_reply}'"
        user_reply = user_reply.sub(search_target, ' ').strip if user_reply
        # Mark all members with this email address as having responded to this message
        @possible_senders.each do |a_member|
          message.process_response(:member => a_member, :text => user_reply, :mode => 'email')
        end
      else
        msg_tag = message_id_tag(:id => msg_id, :action => :create, :location => :body)
        Notifier.send_generic(@from_address, I18n.t('error_msg.invalid_confirmation')).deliver
      end
    end
  end

  def validation_string
    encrypted = encrypt([@user_email, Time.now].to_yaml)
    "Validation: #{encrypted}***********"
  end
  
  # Given a string containing a validation string (or message @body by default),
  # decrypt and check that string. It is valid if the email address is the same as
  # the current user's email address and if the time is less than 24 hours ago.
  def check_validation_string(vstring=@body)
#puts "**** vstring=#{vstring}"
    begin
      decrypted = decrypt(vstring)  # just look for validation string in whole body
      return nil if decrypted.nil?
      email, time_s = YAML.load(decrypted)
      return (email == @user_email) && (Time.now - time_s < 1.day)
    rescue
      puts "**** Error #{$!}"
      return nil
    end
  end

  def encrypt(text)
    cipher = OpenSSL::Cipher.new("AES-128-CBC") 
    cipher.encrypt
    cipher.key = EMAIL_KEY
    iv = cipher.random_iv # also sets the generated IV on the Cipher
    encrypted_data = cipher.update(text) + cipher.final
    combined= Base64.encode64(iv) + Base64.encode64(encrypted_data)
  end

  # Input should be like:
  # Validation: okrQCRqGng8bvWdI1zsVlg==
  # y4P5vq7yAPfsJhgHXiC/0lARyjt5ns9EfltyYz3/gLA=
  # ***********
  # Delimited by "Validation:" and the string of '*'
  # decrypt method returns the decrypted string without those delimiters
  def decrypt(encrypted)
    return nil unless encrypted =~ /Validation: (.*?)\n(.*)\n\*\*\*/m
    begin
      decipher = OpenSSL::Cipher.new("AES-128-CBC")
      decipher.decrypt
  #    puts "**** $1=#{$1}, $2=#{$2}"
      decipher.key = EMAIL_KEY
      decipher.iv = Base64.decode64($1)
      encrypted_data = Base64.decode64($2)
  #    puts "**** decipher.iv=#{Base64.encode64 iv}"
  #    puts "**** encrypted=#{Base64.encode64 encrypted}"
      return decipher.update(encrypted_data) + decipher.final 
    rescue
      return nil
    end 
  end
private

  def process_commands
    successful = true
    from = @from_address
    # Special case for commands 'd' and/or sms = distribute to one or more groups, 
    #   because the rest of the body will be sent without scanning for further commands
    #   ('email' is an alias for 'd'. 
    first_command = @commands[0][0].sub("&", "+").sub('sms', 'd')  # just the command itself, from the first line
    if ['d', 'email', 'd+email', 'email+d'].include? first_command
      result = group_deliver(@body, first_command)
      Notifier.send_generic(from, result).deliver  # Let the sender know success, errors, etc.
      return successful
    end
    @commands.each do |command|
      case command[0]
        when 'help'
          Notifier.send_help(from).deliver
        when 'change', 'update'
          update_member(command[1])  # command[1] is the parameter string
        when 'test'
          Notifier.send_test(from, 
             "You sent 'test' with parameter string (#{command[1]})").deliver
        when 'info'
          do_info(from, @from_member, command[1])
#        when 'directory'
#          @families = Family.those_on_field_or_active.includes(:members, :residence_location).order("name ASC")
#          @visitors = Travel.current_visitors
#          output = WhereIsTable.new(:page_size=>Settings.reports.page_size).to_pdf(@families, @visitors, params)
##puts "IncomingMailsController mailing report, params=#{params}"
#          Notifier.send_report(from, 
#                              Settings.reports.filename_prefix + 'directory.pdf', 
#                              output).deliver
#        when 'travel'
#          selected = Travel.where("date >= ?", Date.today).order("date ASC")
#          output = TravelScheduleTable.new(:page_size=>Settings.reports.page_size).to_pdf(selected)
#          Notifier.send_report(from, 
#                              Settings.reports.filename_prefix + 'travel_schedule.pdf', 
#                              output).deliver
#        when 'birthdays'
#          selected = Member.those_active_sim
#          output = BirthdayReport.new(:page_size=>Settings.reports.page_size).to_pdf(selected)
#          Notifier.send_report(from, 
#                              Settings.reports.filename_prefix + 'birthdays.pdf', 
#                              output).deliver
      else
      end # case
    end # @commands.each
    return successful    
  end # process_commands

  def update_authorized?(target)
    @from_member.roles_include?(:moderator) || target == @from_member
  end

  def update_summary(update_hash)
    "#{update_hash[:members][0].name}: " +
     update_hash[:updates].map {|k,v| "#{k}: #{v}"}.join("; ")
  end              

  def send_confirmation_email(update_hash)
      Notifier.send_generic_hashed(
       :to=> @from_address,
       :subject => 'Update successful',
       :body => "Successful updates #{update_summary(update_hash)}"
          ).deliver
  end

  def send_pls_verify_email(update_hash)
      original_commands = @commands[0].join(' ')
      Notifier.send_generic_hashed(
       :to=> @from_address,
       :subject => 'Please confirm updates',
       :body => "#{original_commands}\n\nThese changes will be made for #{update_summary(update_hash)}\n\n" +
          "To verify, please reply to this email, being sure to leave the verification code " +
          "below intact.\n\n#{validation_string}"
          ).deliver
  end

  def update_member(values)
    update_hash = Member.parse_update_command(values)
#puts "**** update_hash=#{update_hash}"
    case
      when update_hash.nil?
        Notifier.send_generic_hashed(
         :to=> @from_address,
         :subject => 'Error in your update command',
         :body => "Error in your update command. The name was not found or not given.\n\n" +
            values).deliver
      when update_hash[:members].many?
        names = update_hash[:members].map {|m| m.name}.join('; ')
        Notifier.send_generic_hashed(
         :to=> @from_address,
         :subject => 'More info needed for your update command',
         :body => "More than one person fits the name you sent in the command\n\n" +
            values +
            "\n\nThese were: #{names}\n\nPlease select one name and retry the update."
            ).deliver
      else
        target = update_hash[:members][0]
        if update_authorized?(target)
          if check_validation_string(@body)
            target.update_attributes(update_hash[:updates])
            send_confirmation_email(update_hash)
          else
            send_pls_verify_email(update_hash)
          end
        else
          Notifier.send_generic_hashed(
           :to=> @from_address,
           :subject => 'Update not successful',
           :body => "Only moderators are allowed to change other people's contact information.\n\n" +
            values).deliver
        end          
    end
  end

  def do_info(from, from_member, name)
    members = Member.find_with_name(name)
    Notifier.send_info(from, from_member, name, members).deliver
  end

#  def do_location(text)
#    @sender.update_reported_location(text)
#    Notifier.send_generic(from, 'Your location has been updated to ' + text).deliver
#  end  

  # Accept messages from approved groups, and those directed only to moderators
  def accepted_groups(group_names_string)
    return [:administrator, :moderator, :member].include? @privileges ||
               group_names_string =~ /\A(mods|moderators)\Z/i
  end

  def validate_groups(group_names_string)
    group_names = group_names_string.gsub(/;|,/, ' ').split(/\s+/)  # e.g. ['security', 'admin']
    group_ids = Group.ids_from_names(group_names)   # e.g. [1, 5, 'badGroupName']
    valid_group_ids = group_ids.map {|g| g if g.is_a? Integer}.compact
    valid_group_names = valid_group_ids.map{|g| Group.find(g).group_name}
    invalid_group_names = (group_ids - valid_group_ids)
    return {:valid_group_names => valid_group_names, :invalid_group_names => invalid_group_names, 
            :valid_group_ids => valid_group_ids}
  end

  def confirmation_message(body, use_sms, valid_group_names, invalid_group_names)
    body_joined = format_text(body[0..149])
    confirmation = t(:group_msg_sent_conf, :body=>body_joined, :groups => valid_group_names.join(', '))
    if use_sms && body.length > 150 
      confirmation << t(:sms_length_warning)
    end 
    unless invalid_group_names.empty?
      if invalid_group_names.size == 1
        confirmation << t(:missing_group_warning, :invalid_groups => invalid_group_names[0])
      else
        confirmation << t(:missing_groups_warning, 
          :invalid_groups => smart_join(invalid_group_names, ', ', '&'))
      end
    end
    return confirmation
  end

  def use_email?(command)
    (command =~ /e/) ? true : false
  end

  def use_sms?(command)
    (command =~ /d/) ? true : false
  end

  def setup_message(body, command, group_ids)
    # If command is like 'email'... use email. If it's like 'd' use sms.
    #  (This could be done more elegantly but the method below works well with testing)
    use_email = use_email?(command)
    use_sms   = use_sms?(command)
    sms_only = body[0..149] if use_sms
#puts "**** setup_message: group_ids=#{group_ids}"
    return Message.create(:to_groups=>group_ids, :body=>body, 
                :send_email => use_email, :send_sms => use_sms, :sms_only => sms_only)
  end

  # Just any elementary reformatting ...
  def format_text(text)
    # Reflow
    reformatted = text.gsub(/\s*\n\s*\n+/, '$#$').gsub(/\s*\n\s*/, ' ').gsub('$#$', "\n\n")
    return reformatted
  end

  # Needs refactoring!
  def group_deliver(text, command)
    unless text =~ /\A\s*\S+\s+(.*?):\s*(.*)/m  # "d <groups>: <body>..."  (body is multi-line)
      return I18n.t('error_msg.unparsable_group_deliver', :text => text)
    end
    body = format_text($2)   # All the rest of the message, from match above (text =~ ...)
    group_names_string = $1
    accepted = accepted_groups(group_names_string)
    # This 'unless' clause disallows those below member status from sending to groups
    # If they try, then the message is sent to the moderators ('cause maybe it's important!)
    # and an error message is returned.
    unless accepted
      group_names_string='Moderators'
      body = I18n.t(:Rejected) + ': ' + body
    end
    groups_checked = validate_groups(group_names_string)
    valid_group_ids = groups_checked[:valid_group_ids]
    valid_group_names = groups_checked[:valid_group_names]
    invalid_group_names = groups_checked[:invalid_group_names]
    if valid_group_ids.empty?
      return I18n.t('error_msg.no_groups_found', :command => command, :group_names_string => group_names_string)
    end
    message = setup_message(body, command, valid_group_ids)
    message.deliver  # Don't forget to deliver!
    if accepted
      return confirmation_message(body, use_sms?(command), valid_group_names, invalid_group_names)
    else
      return I18n.t('error_msg.group_deliver_not_allowed')
    end
  end

end # Class

