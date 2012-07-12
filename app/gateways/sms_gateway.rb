require 'twiliolib'
require 'application_helper'
include ApplicationHelper
require 'httparty'
require 'uri'

# Convenient way to send SMS. 
# * Extracts parameters from the SiteSettings upon initialization
# * Gives error if any of the required settings are not found
# * provides stub "send" method which saves body and phone numbers to instance variables and generates log entry
#
# * SmsGateway itself is not functional; actual sending must be defined in the sub-class
#   such as ClickatellGateway.
# 
# Numbers is an array of phone numbers as strings. They should be in full international form.
# The initial plus sign is not needed and is stripped if present.
#
# Example:
#   gateway = ClickatellGateway.new
#   if gateway.status[:errors] 
#     (handle setup problem; probably some parameters are missing from the setup/configuration)
#   end
#   gateway.send(["+2345551111111]", "Security alert!")
#   if gateway.status == ...
#
# See class definition of ClickatellGateway as an example of how to define a new gateway. 
#
class SmsGateway
  attr_accessor :numbers, :body, :required_params
  attr_reader :uri, :gateway_reply, :gateway_name, :errors

  def initialize
    get_required_params if @required_params && !@required_params.empty?
    @gateway_name ||= 'SmsGateway'
  end

  def get_required_params
    missing = []
    @required_params.each do |param|
      param_value = get_site_setting(param)
      if param_value.nil?
        missing << param
      else
        self.instance_variable_set "@#{param.to_s}", param_value
      end
    end
    unless missing.empty?
      @errors ||= []
      @errors << missing.join(', ')
    end
  end
      
  def get_site_setting(setting)
    begin
      return SiteSetting.send "#{@gateway_name}_#{setting}".to_sym
    rescue
      return nil
    end      
  end      

  def numbers_to_string_list
    if @numbers.is_a? String
      num_array = @numbers.split(/,\s*/)
    else
      num_array = @numbers
    end 
    return num_array.join(',')
  end
    
  def deliver(numbers=@numbers, body=@body)
    @numbers=numbers
    @body=body
    log_numbers = numbers_to_string_list
    log_numbers = log_numbers[0..49]+'...' if log_numbers.length > 50
    AppLog.create(:code => "SMS.sent.#{@gateway_name}", :description=>"to #{@numbers}: #{@body[0..30]}, resp=#{@gateway_reply}")
    return @gateway_reply
  end
end


