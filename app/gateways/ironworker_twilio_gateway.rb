require 'application_helper'
include ApplicationHelper

class IronworkerTwilioGateway < SmsGateway

  def initialize
    @gateway_name = 'twilio'  # This causes the parameters such as account_id to be retrieved from the Twilio parameters
    @required_params = [:account_sid, :auth_token, :phone_number]  
    super
    @gateway_name = 'ironworker_twilio'  # This will be the "permanent" name
AppLog.create(:code => "SMS.init.#{@gateway_name}", :description=>"initialized")
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
    @numbers.each do |number|
#puts "****Delivering to number=#{number}"
      begin
        iron_worker.tasks.create("twilio_worker",
          {:sid => @account_sid,
            :token => @auth_token,
            :from => @phone_number,
            :to => number.with_plus,
            :message => @body
          }
         )
       end     
    end
    AppLog.create(:code => "SMS.sent.#{@gateway_name}", :description=>"Queued #{@numbers.count} messages.")
    @gateway_reply = nil
    super
  end
end  

