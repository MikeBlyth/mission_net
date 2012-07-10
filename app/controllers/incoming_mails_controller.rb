require 'application_helper'
class IncomingMailsController < ApplicationController
  require 'mail'
  skip_before_filter :verify_authenticity_token

  def create  # need the name 'create' to conform with REST defaults, or change routes
#puts "IncomingController create: params=#{params}"
    @from_address = params['from']
    @possible_senders = from_member()
#puts "**** Contacts=#{Contact.all.each {|c| c.email_1}.join(' ')}"
#puts "**** @possible_senders=#{@possible_senders}"
    @from_member = @possible_senders.first
# puts "**** @from_member=#{@from_member}"
    if @from_member.nil?
      render :text => 'Refused--unknown sender', :status => 403, :content_type => Mime::TEXT.to_s
      return
    end
    @subject = params['subject']
    @body = params['plain']
    process_message_response
    commands = extract_commands(@body)
    if commands.nil? || commands.empty?
      Notifier.send_generic(@from_address, "Error: nothing found in your message #{@body[0..160]}")
      success = false
    else
      success = process_commands(commands)
    end

    # if the message was handled successfully then send a status of 200,
    #   else give a 422 with the errors
    if success
      render :text => "Success", :status => 200, :content_type => Mime::TEXT.to_s
    else
      render :text => 'Error: Email commands not recogized', :status => 422, :content_type => Mime::TEXT.to_s
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
        @possible_senders.each do |a_member|
          message.process_response(:member => a_member, :text => user_reply, :mode => 'email')
        end
      else
        msg_tag = message_id_tag(:id => msg_id, :action => :create, :location => :body)
        Notifier.send_generic(@from_address, "Error: It seems you tried to confirm message ##{msg_id}, " +
           "but you don't seem to have a message with that ID. Maybe you should contact the sender " +
           "in person to confirm that you received the message, if that is what you meant to do.").deliver
      end
    end
  end

  # Is this message from someone in our database?
  # (look for a contact record having an email_1 or email_2 matching the message From: header)
  def from_member
    Member.find_by_email(@from_address)
#    from = params['from']
#    matching_contact = Contact.where('email_1 = ? OR email_2 = ?', from, from).first 
#puts "**** matching_contact=#{matching_contact}, from=#{params['from']}"
#    @from_member = matching_contact ? matching_contact.member : nil
  end  

private

  def process_commands(commands)
    successful = true
    from = params['from']
    # Special case for commands 'd' and/or sms = distribute to one or more groups, 
    #   because the rest of the body will be sent without scanning for further commands
    #   ('email' is an alias for 'd'. 
    first_command = commands[0][0].sub("&", "+").sub('sms', 'd')  # just the command itself, from the first line
    if ['d', 'email', 'd+email', 'email+d'].include? first_command
      result = group_deliver(@body, first_command)
      Notifier.send_generic(from, result).deliver  # Let the sender know success, errors, etc.
      return successful
    end
    commands.each do |command|
      case command[0]
        when 'help'
          Notifier.send_help(from).deliver
        when 'test'
          Notifier.send_test(from, 
             "You sent 'test' with parameter string (#{command[1]})").deliver
        when 'info'
          do_info(from, @from_member, command[1])
        when 'directory'
          @families = Family.those_on_field_or_active.includes(:members, :residence_location).order("name ASC")
          @visitors = Travel.current_visitors
          output = WhereIsTable.new(:page_size=>Settings.reports.page_size).to_pdf(@families, @visitors, params)
#puts "IncomingMailsController mailing report, params=#{params}"
          Notifier.send_report(from, 
                              Settings.reports.filename_prefix + 'directory.pdf', 
                              output).deliver
        when 'travel'
          selected = Travel.where("date >= ?", Date.today).order("date ASC")
          output = TravelScheduleTable.new(:page_size=>Settings.reports.page_size).to_pdf(selected)
          Notifier.send_report(from, 
                              Settings.reports.filename_prefix + 'travel_schedule.pdf', 
                              output).deliver
        when 'birthdays'
          selected = Member.those_active_sim
          output = BirthdayReport.new(:page_size=>Settings.reports.page_size).to_pdf(selected)
          Notifier.send_report(from, 
                              Settings.reports.filename_prefix + 'birthdays.pdf', 
                              output).deliver
      else
      end # case
    end # commands.each
    return successful    
  end # process_commands

  def do_info(from, from_member, name)
    members = Member.find_with_name(name)
    Notifier.send_info(from, from_member, name, members).deliver
  end

  def do_location(text)
    @sender.update_reported_location(text)
    Notifier.send_generic(from, 'Your location has been updated to ' + text).deliver
  end  

  def group_deliver(text, command)
    unless text =~ /\A\s*\S+\s+(.*?):\s*(.*)/m  # "d <groups>: <body>..."  (body is multi-line)
      return("I don't understand. To send to groups, separate the group names with spaces" +
             " and be sure to follow the group or groups with a colon (':')." +
             "\n\nFor example, \"email admin: This is a message for admin.\"" +
             " \n\nWhat I got was \"#{text}.\"")
    end
    body = $2   # All the rest of the message, from match above (text =~ ...)
    group_names_string = $1
    group_names = group_names_string.gsub(/;|,/, ' ').split(/\s+/)  # e.g. ['security', 'admin']
    group_ids = Group.ids_from_names(group_names)   # e.g. [1, 5]
    valid_group_ids = group_ids.map {|g| g if g.is_a? Integer}.compact
    valid_group_names = valid_group_ids.map{|g| Group.find(g).group_name}
    invalid_group_names = group_ids - valid_group_ids   # This will be names of any groups not found
    if valid_group_ids.empty?
      return("You sent the \"d\" command which means to forward the message to groups, but " +
          "no valid group names or abbreviations found in \"#{group_names_string}.\" ")
    end
    sender_name = @from_member.full_name_short
    # If command is like 'email'... use email. If it's like 'd' use sms.
    #  (This could be done more elegantly but the method below works well with testing)
    use_email = (command =~ /e/) ? true : false
    use_sms   = (command =~ /d/) ? true : false
    message = Message.create(:to_groups=>valid_group_ids, :body=>body, 
        :send_email => use_email, :send_sms => use_sms)
    message.deliver  # Don't forget to deliver!
    confirmation = "Your message #{body[0..120]} was sent to groups #{valid_group_names.join(', ')}. "
    unless invalid_group_names.empty?
      if invalid_group_names.size == 1
        confirmation << "Group #{invalid_group_names} was not found, so did not receive message."
      else
        confirmation << "Groups #{invalid_group_names.join(', ')} were not found, so did not receive messages."
      end
    end
    return confirmation
  end

end # Class

