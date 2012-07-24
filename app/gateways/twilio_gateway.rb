require 'twilio-ruby'
require 'application_helper'
include ApplicationHelper
require 'httparty'
require 'uri'

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
    @required_params = [:account_sid, :auth_token, :phone_number]  # "twilio_" is automatically prefixed to these for looking in the site settings
    super
#puts "**** @account_sid=#{@account_sid}"
#puts "**** @auth_token=#{@auth_token}"
AppLog.create(:code => "SMS.connect.#{@gateway_name}", :description=>"@account_sid=#{(@account_sid || '')[0..6]}..., @auth_token=#{(@auth_token || '')[0..4]}...")
#puts "**** Create Twilio Client:"
    @client = Twilio::REST::Client.new @account_sid, @auth_token
#puts "****   Client = #{@client}.attributes"    
  end

  # send an sms using Twilio-ruby interface
  # No error checking done in this method. Should eventually be added.
  #   See http://www.twilio.com/docs/api/rest/sending-sms for how to do status callbacks
  def deliver(numbers=@numbers, body=@body)
    # NB: message#deliver_sms currently sends numbers as a string, not an array.
    if numbers.is_a? String
      @numbers = numbers.gsub("+","").split(/,\s*/)    # Convert to array so we can do "each"
    else
      @numbers = numbers
    end
    @body = body        #  ...
    raise('No phone numbers given') unless @numbers
    raise('No message body') unless @body
    reply = {} # To make status hash
    @numbers.each do |number|
      begin
        @client.account.sms.messages.create(
          :from => @phone_number,
          :to => number.with_plus,
          :body => @body
         )
        rescue  # twilio-ruby indicates failed phone number by raising exception Twilio::REST::RequestError
          AppLog.create(:code => "SMS.error.twilio", :description=>"#{$!}, #{$!.backtrace[0..2]}", :severity=>'Warning')  
          reply[number] = {:status => MessagesHelper::MsgError}
        else
          AppLog.create(:code => "SMS.sent.#{@gateway_name}", :description=>"from=#{@phone_number}, to=#{number}, msg=#{@body[0..30]}")
          reply[number] = {:status => MessagesHelper::MsgSentToGateway}
       end     
    end
    @gateway_reply = reply
    super
  end

end  

