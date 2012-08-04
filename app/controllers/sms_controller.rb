require 'application_helper'
include ApplicationHelper
require 'httparty'
require 'uri'
require 'sms_gateway'
#include SessionHelper
include SmsGatewaysHelper

class SmsController < ApplicationController
  include HTTParty
  skip_before_filter :verify_authenticity_token, :authorize

  # Create - handle incoming SMS message from TWILIO (Will need adjustment if other gateway is used)
  #
  # Twilio sends the message to create just as if it were a web HTTP request
  # The create method should handle the incoming message by determining any actions
  # needed and sending a return message.
  # ToDo
  # Remove line for testing; configure for other gateways
  def create  # need the name 'create' to conform with REST defaults, or change routes
 #puts "**** IncomingController create: params=#{params}"
    @from = params[:From]  # The phone number of the sender
#debugger
    body = params[:Body]  # This is the body of the incoming message
    AppLog.create(:code => "SMS.incoming", :description=>"from=#{@from}; body=#{body[0..50]}")
    params.delete 'SmsSid'
    params.delete 'AccountSid'
    params.delete 'SmsMessageSid'
    @possible_senders = from_members  # all members from this database with matching phone number
    @sender = @possible_senders.first # choose one of them
    if @sender  # We only accept SMS from registered phone numbers of members
      begin
        AppLog.create(:code => "SMS.received", :description=>"from #{@from} (#{@sender.shorter_name}): #{body}")
        resp = (process_sms(body) || '')[0..159]    # generate response
        AppLog.create(:code => "SMS.reply", :description=>"to #{@from}: #{resp}")
#        default_sms_gateway.deliver(@from, resp) #default_gateway in messages_helper creates an instance of gateway specified 
#                                            #  in SiteSettings default_outgoing_sms_gateway
        render :text => resp, :status => 200, :content_type => Mime::TEXT.to_s  # Confirm w incoming gateway that msg received
#      rescue
#        AppLog.create(:code => "SMS.system_error", :description=>"on SMS#create: #{$!}, #{$!.backtrace[0..2]}")
#        render :text => "Internal", :status => 500, :content_type => Mime::TEXT.to_s
#        ClickatellGateway.new.deliver(@from, "Sorry, there is a bug in my system and I crashed :-(" )
      end
    else  
      AppLog.create(:code => "SMS.rejected", :description=>"from #{@from}: #{body}")
      render :text => "Refused: sender's phone number is not recognized", 
          :status => 403, :content_type => Mime::TEXT.to_s
    end
  end 
  

private

  # Parse the message received from mobile
  def process_sms(body)
    return "Nothing found in your message!" if body.blank?
    command, text = extract_commands(body)[0] # parse to first word=command, rest = text
    return case command.downcase
       when 'd' then group_deliver(text)
       when 'group', 'groups' then do_list_groups
       when 'info' then do_info(text)  
#           when 'location' then do_location(text)  
       when 'update', 'updates' then send_updates(text)
       when '?', 'help' then do_help(text)
       when /\A!/ then process_response(command, text)
       # More commands go here ...
       else
         unsolicited_response(body) ||
           "Unknown command '#{command}'. Send HELP for instructions. If u want to reply to a msg u received, pls contact " + 
             "the sender directly. Don't use this number."
#             "unknown command '#{command}'. Info=" + (do_info(text) if Member.find_with_name(text))
       end
  end

  def unsolicited_response(body)
    last_sent_message = SentMessage.where(:member_id => @sender.id).order('created_at DESC').first
#puts "**** last_sent_message=#{last_sent_message}"
    return nil if last_sent_message.nil? || (Time.now - last_sent_message.created_at) > 6.hours
    last_message_sender = Member.find last_sent_message.message.user_id
    msg = "<=#{@from} #{@sender.shorter_name}: #{body}"
    if last_message_sender
      SmsGateway.default_sms_gateway.deliver(last_message_sender.phone_1, msg)
      return "I forwarded your msg to #{last_message_sender.shorter_name}. It would be better to contact him/her" +
             " directly at #{last_message_sender.phone_1}."
    end
    return nil
  end

  # Return help
  # ToDo -- add specific help about commands
  def do_help(text)
    command_summary = [ ['d <group>', 'deliver msg to grp'], 
                        ['groups', 'list main grps'],
                        ['info <name>', 'get contact info'],
                        ['updates', 'get updates'],
#                        ['location <place>', 'set current loc'],
                        ['!21 <reply>', 'reply to msg 21']
                      ]
    command_summary.map {|c| "#{c[0]} = #{c[1]}"}.join("\n")
  end
  
  # Send a list of abbreviations for the "primary" groups (primary meaning that)
  # they're important enough to fit into this 160-character string
  def do_list_groups()
    "Some groups: " + Group.primary_group_abbrevs
  end                    
  
#  def do_location(text)
##puts "****do_location text=#{text}, @sender=#@sender"
#    if text
#      if text =~ /( for|next|for next)?\s([\d]+)/
#        duration = $2.to_i  # the number of hours
#        location = $`.strip  # part preceding the match, i.e. the location itself
##puts "****location=#{location}, duration=#{duration}"
#      else
#        duration = DefaultReportedLocDuration
#        location = text.strip
#      end
#      location.sub!(/\A(in |at )/, '')
##puts "**** location after sub=#{location}"
#      @sender.update_reported_location(location, Time.now, Time.now + duration*3600) # last is expiration time, now + duration hours
#      return "Your location has been updated to #{location} for the next #{duration} hours."
#    else
#      return "I don't understand. Say something like \"location JETS next 6 hours\" or " +
#             "\"location office\" or even just \"location HQ 6\". "
#    end
#  end  

  # Return info about an individual named in text  
  def do_info(text)
    member = Member.find_with_name(text).first  
    if member
      return (member.last_name_first(:initial=>true) + ' ' + contact_info(member) + '. ')
    else
      return "#{text} not found in database"
    end
  end    
  
  def contact_info(member)
      email = member.contact_summary['Email'].split(',')[0] # use only the first email address
      return "#{member.contact_summary['Phone']} #{email}" 
  end

  def group_deliver(text)
#puts "**** group_deliver"    
    target_group, body = text.sub(' ',"\x0").split("\x0") # just a way of stripping the first word as the group name
    group = Group.find(:first, 
      :conditions => [ "lower(group_name) = ? OR lower(abbrev) = ?", target_group.downcase, target_group.downcase])
    if group   # if we found the group requested by the sender
      sender_name = @sender.shorter_name
      body = body[0..148-sender_name.size] + '-' + sender_name  # Truncate msg and add sender's name
      message = Message.new(:user_id => @sender.id, :send_sms=>true, :to_groups=>group.id, :sms_only=>body)
      message.deliver  # Don't forget to deliver!
      return("Your message ##{message.id} is being sent to #{group.group_name} (#{message.members.count} recipients)")
    else
      return( ("Error: no group #{target_group}. Send command 'groups' to list the main ones incl " +
               Group.primary_group_abbrevs)[0..160] )
    end
  end

  def send_updates(text)
    # The regular expression is to look for keyword(s) and/or limit (integer) in either order
    if text+' ' =~ /\A\s*(\d+)\W*(.*)/
      limit, keyword = $1, $2
    else
      text+' ' =~ /\s*(\w.*?)[, :\/\(]+(\d*)/
      limit, keyword = $2, $1 
    end
    limit = limit.blank? ? nil : limit.to_i
    keyword = keyword.blank? ? nil : keyword.strip
    updates = Message.news_updates(:keyword => keyword, :limit => limit)
    found_without_keyword = false
    # If we found no updates *with* the keyword, then try searching without the keyword and send last 2 entries
    if keyword && updates.empty?
      updates = Message.news_updates(:limit => 2)  # try again with no keywords
      found_without_keyword = updates.any?
    end
    updates.each do |u|
      u.deliver_sms(:phone_numbers => @from, :news_update => true) # Don't try to use delayed-job here w present DJ/Heroku setup
    end
    return "No new updates with keyword(s) '#{keyword}'. The last one or two updates are being sent." if found_without_keyword
    return "Sending #{updates.count} updates" if updates.any? 
    return "No new updates found. Contact your organization if you need more information."
  end

  # The user has sent an SMS text confirming response of a previous message
  def process_response(command, text)
    message_id = command[1..99]
    message = Message.find_by_id(message_id)
#puts "**** command=#{command}, text=#{text}, @sender.id=#{@sender.id}, message=#{message.id}"
    if message
      @possible_senders.each do |a_member|
        message.process_response(:member => a_member, :response => text, :mode => 'SMS')
      end
      return("Thanks for your response :-)")
    else
      return("Thanks for responding, but message number #{message_id} was not found. Check the number again.")
    end
##    target = SentMessage.where("member_id = ? AND message_id = ?", @sender.id, command[1..99].to_i)[0]
#    target = SentMessage.where("member_id = ?", @sender.id)[0]
#puts "**** target=#{target}"
#target.should_not == nil
    return ''
  end

  def from_members
    Member.find_by_phone(@from)
  end

end # Class

