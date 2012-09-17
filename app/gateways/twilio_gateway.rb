require 'twilio-ruby'
require 'application_helper'
include ApplicationHelper
require 'httparty'
require 'uri'
include HerokuHelper
require 'iron_worker_ng'

# This is a thin wrapper around twilio-ruby to make it compatible with the "Gateway" class
# See https://github.com/twilio/twilio-ruby/wiki

class TwilioGateway < SmsGateway
  # Initialize method should set the name of this gateway and list all the needed parameters.
  # Parent SmsGateway initialization will set instance variables corresponding to those parameters.
  # In this ClickatellGateway class, then, after initialization we will have @user_name, @password, and @api_id
  # extracted from the SiteSettings.
  # The initialize method could also set those variables itself (but then they won't be accessible to users)

  def initialize
    @gateway_name = 'twilio'
    @required_params = [:account_sid, :auth_token, :phone_number, :background]  # "twilio_" is automatically prefixed to these for looking in the site settings
    super
    #AppLog.create(:code => "SMS.connect.#{@gateway_name}", :description=>"@account_sid=#{(@account_sid || '')[0..6]}..., @auth_token=#{(@auth_token || '')[0..4]}...")
#puts "**** Create Twilio Client:"
#puts "****   Client = #{@client}.attributes"    
  end

  # send an sms using Twilio-ruby interface
  # No error checking done in this method. Should eventually be added.
  #   See http://www.twilio.com/docs/api/rest/sending-sms for how to do status callbacks
  def deliver(numbers=@numbers, body=@body, message_id=nil, log=nil)
    # NB: message#deliver_sms currently sends numbers as a string, not an array.
puts "**** Delivering Twilio with @background=#{@background}, numbers=#{numbers}"
    if numbers.is_a? String
      @numbers = numbers.gsub("+","").split(/,\s*/)    # Convert to array so we can do "each"
    else
      @numbers = numbers
    end
    @body = body        #  ...
    raise('No phone numbers given') unless @numbers
    raise('No message body') unless @body
    # Use delivery system based on the parameter @background [i.e. background processing type]
    case @background
      when /iron/i
        @numbers.count > 1 ? deliver_ironworker : deliver_direct(message_id)
      when /dj|delay.*job/i
         @numbers.count > 1 ? deliver_delayed_job(message_id) : deliver_direct(message_id)
      else
        deliver_direct(message_id)
    end
    AppLog.create(:code => "SMS.deliver.#{@gateway_name}", :description=>"background=#{@background || 'none'}, count = #{@numbers.count} messages")
    super
  end

  def iron_worker
    @iron_worker_client ||= IronWorkerNG::Client.new
  end  

  def deliver_ironworker
    iron_worker
    @iron_worker_client.tasks.create("twilio_multi_worker",
      {:sid => @account_sid,
        :token => @auth_token,
        :from => @phone_number,
        :numbers => @numbers,
        :body => @body
      }
      )
    @status = nil    # because job will be run later, asynchronously
  end
  
  def deliver_delayed_job(message_id)
    heroku_set_workers(1)   # For Heroku deployment only, of course. Need a worker to get the deliveries done in background.
    delay.deliver_direct(message_id)
    @status = nil    # because job will be run later, asynchronously
  end

  def deliver_direct(message_id)
    @client = Twilio::REST::Client.new @account_sid, @auth_token
    @status = {} # To make status hash
    @numbers.each do |number|
#puts "****Delivering to number=#{number}"
      begin
        @client.account.sms.messages.create(
          :from => @phone_number,
          :to => number.with_plus,
          :body => @body
         )
        rescue  # twilio-ruby indicates failed phone number by raising exception Twilio::REST::RequestError
          if (member = Member.find_by_phone(number).first)
            for_member = "for #{member.full_name_short}: "
          else
            for_member = ''
          end
          AppLog.create(:code => "SMS.error.twilio", :description=>"#{for_member}#{$!}, #{$!.backtrace[0..2]}", :severity=>'Warning')  
          @status[number] = {:status => MessagesHelper::MsgError}

        else
          @status[number] = {:status => MessagesHelper::MsgSentToGateway}
       end
    end
    AppLog.create(:code => "SMS.sent.#{@gateway_name}", 
      :description=>"#{@numbers.count} messages sent from=#{@phone_number}, msg=#{@body[0..30]}")
    if @status && message_id && (msg = Message.find_by_id(message_id))
      msg.update_sent_messages_w_status(@status)
    end
    @status= nil  # because we've already updated the sent messages
  end
end  

