#require Rails.root.join('spec/factories')
#require Rails.root.join('spec/spec_helper')
class MockTwilioGateway < TwilioGateway
  # Used for testing only (obviously, since it's in the testing library :-)
  # Set mock_response via first argument (response) or by @mock_response
  attr_accessor :mock_response, :members, :options
  def initialize(response=nil, members=[], options={})
    super()
    @mock_response = response
#    @members = members
#    @options = options
  end
  
#  def error_response
#    "ERR: 105, INVALID DESTINATION ADDRESS"
#  end

  def generate_response
  end

  def deliver(numbers=@numbers, body=@body)
#puts "****MockClickatellGateway#Deliver numbers=#{numbers}, body=#{body}"
    @numbers = numbers
    @body = body
    @gateway_reply = @mock_response.blank? ? generate_response : @mock_response
    unless @options[:no_log]
      AppLog.create(:code => "SMS.sent.#{@gateway_name}", :description=>"to #{@numbers}: #{@body[0..30]}, resp=#{@gateway_reply}")
    end
    return @gateway_reply
  end  
end  # Of MockClickatellGateway


