require 'application_helper'
include ApplicationHelper
require 'httparty'
require 'uri'

class ClickatellGateway < SmsGateway
  # Initialize method should set the name of this gateway and list all the needed parameters.
  # Parent SmsGateway initialization will set instance variables corresponding to those parameters.
  # In this ClickatellGateway class, then, after initialization we will have @user_name, @password, and @api_id
  # extracted from the SiteSettings.
  # The initialize method could also set those variables itself (but then they won't be accessible to users)

  silence_warnings do 
    ClickatellStatusCodes = {
      1 => {:our_status=>-1, :description=>"The message ID is incorrect or reporting is delayed."},
      2 => {:our_status=>1, :description=>"The message could not be delivered and has been queued for attempted redelivery."},
      3 => {:our_status=>1, :description=>"Delivered to gateway."},
      4 => {:our_status=>2, :description=>"Received by handset."},
      5 => {:our_status=>-1, :description=>"Error with message, likely problem with content"},
      6 => {:our_status=>-1, :description=>"User canceled delivery"},
      7 => {:our_status=>-1, :description=>"Error with message"},
      8 => {:our_status=>1, :description=>"Message received by gateway."},
      9 => {:our_status=>-1, :description=>"Routing error"},
      10 => {:our_status=>-1, :description=>"Message expired"},
      11 => {:our_status=>-1, :description=>"Message queued for later delivery"},
      12 => {:our_status=>-1, :description=>"Out of credit"},
      14 => {:our_status=>-1, :description=>"Maximum MT limit exceeded"}
      }

    ExpiredSessionCode = '003'
    AuthenticationFailedCode = '001'  
  end

  def initialize
    @gateway_name = 'clickatell'
    @required_params = [:user_name, :password, :api_id]
puts "**** Clickatell gateway initialized"
    super
  end

  def credentials
    "user=#{@user_name}&password=#{@password}&api_id=#{@api_id}"
  end
  
  def base_uri
    "http://api.clickatell.com/http/"
  end

  # Send a message (@body) to a phone (@numbers)
  # If using a RESTFUL interface or other where a URI is called, you can follow this model. Otherwise,
  # this method will have to do whatever needed to tell the gateway service to send the message.
  def deliver(numbers=@numbers, body=@body, *)
puts "**** deliver Clickatell, numbers=#{numbers}"
    @numbers = numbers  # Update instance variables (matters only if they were included in this call)
    @body = body
    raise('No phone numbers given') unless @numbers
    raise('No message body') unless @body
    outgoing_numbers = numbers_to_string_list
    @uri = base_uri + "sendmsg?&callback=2" +
            "&to=#{outgoing_numbers}&text=#{URI.escape(body)}"
    call_gateway
    @status = make_status_hash
    super  # Note that it's called AFTER we make the connection to Clickatell, so it can include
           #   the results in the log.
  end

  def make_status_hash
    @numbers.count == 1 ? status_of_single_message : status_of_multiple_messages
  end
  
  # Return status hash like {'23480888888' => {:status => -1, :error => 'ERROR: No credit'}}
  # or                      {'23480888888' => {:status => 2, :sms_id => '23abxx3278ljix9neh'}
  def status_of_single_message
    if @gateway_reply =~ /ID: (\w+)/
      return {@numbers[0] => {:status => MessagesHelper::MsgSentToGateway, :sms_id => @gateway_reply.body[4..99]}}
    else
      return {@numbers[0] => {:status => MessagesHelper::MsgError, :error => @gateway_reply.body}}
    end
  end
  
  # Just like status_of_single_message, but multiple. Need separate method because Clickatell uses different format
  #   for status of single and multiple messages
  def status_of_multiple_messages
    #  Parse the Clickatell reply into array of hash like {:id=>'asebi9xxke...', :phone => '2345552228372'}
#puts "**** @gateway_reply=#{@gateway_reply}"
    status_hash = {}
    @gateway_reply.split("\n").each do |s|
      if s =~ /ID:\s+(\w+)\s+To:\s+([0-9]+)/
        status_hash[$2] = {:sms_id => $1, :status => MessagesHelper::MsgSentToGateway}
      end
    end
    # Any sent_messages not now marked with gateway_message_id and msg_status must have errors
    @numbers.each do |number|
      unless status_hash.has_key? number
        status_hash[number] = {:status=> MessagesHelper::MsgError}
      end
    end
    return status_hash
  end

  # Get the status for message with Clickatell ID = gw_msg_id
  def query(gw_msg_id)
    unless gw_msg_id.blank?
      @uri = base_uri + "querymsg?apimsgid=#{gw_msg_id}"
      call_gateway
      # If we got the status, then the ID will match the one we asked for and there will be Status: nnn
      if @gateway_reply.body =~ /ID: (\w+) Status: (\w+)/ && ($1 == gw_msg_id)
        return ClickatellStatusCodes[$2.to_i][:our_status]
      else
        return @gateway_reply.body
      end
    end
  end
            
  # Clickatell uses sessions as an alternative to basic authentication. 
  def get_session
    session_uri = base_uri.sub('http://', 'https://') + "auth?" + credentials
    reply = HTTParty::get session_uri
    if reply.body =~ /OK: (\w+)/
      @session = $1
      return @session
    else
      @session = nil
      return reply.body   # Which contains the error message
    end
  end
    
  def session_expired
    @gateway_reply.body =~ Regexp.new("(Err: #{ExpiredSessionCode})|(Err: #{AuthenticationFailedCode})", 'i')
  end
  
  def uri_with_session
    @uri+"&session_id="+@session
  end
      
  # Connect to Clickatell via the URI.
  # This can be overridden for testing; mock method can simply provide the desired reply
  def call_gateway
    if @uri =~ /password=/   # If we're using user_name and password, no need for session
      @gateway_reply = HTTParty::get @uri
    else
      resp = get_session if @session.nil?  # 
      raise "Failed to get Clickatell session, got '#{resp}'" if @session.nil?
      @gateway_reply = HTTParty::get uri_with_session 
      # If we have used a session to call, and there is no valid session, then get one
      if session_expired
        get_session
        @gateway_reply = HTTParty::get uri_with_session 
      end
    end
#puts "**** CGtw#deliver @gateway_reply=#{@gateway_reply}"
  end
      
 
  def self.parse_status_params(params)
    gateway_msg_id = params[:apiMsgId]
#puts "**** params[:apiMsgId]=#{params[:apiMsgId]}, quoted=#{params['apiMsgId']}"
    status = decode_status(params[:status])
    return {:gateway_msg_id => gateway_msg_id, 
      :updates=>{:msg_status=>status, :confirmed_time=> Time.now }  # These are the changes applied to sent_message
      }
  end

  def self.decode_status(gateway_reported_status)
    return ClickatellStatusCodes[gateway_reported_status.to_i][:our_status]
  end
end  

