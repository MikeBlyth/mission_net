#require Rails.root.join('spec/factories')
#require Rails.root.join('spec/spec_helper')
class MockClickatellGateway < ClickatellGateway
  # Used for testing only (obviously, since it's in the testing library :-)
  # Set mock_response to literally what you want it to be or
  # Set members to an array of members (who must have primary_contacts defined)
  #   and the response will be generated based on the phone numbers of those members
  attr_accessor :mock_response, :members, :options
  def initialize(response=nil, members=[], options={})
    super()
    @mock_response = response
    @members = members
    @options = options
  end
  
  # Generate a Clickatell-style response like
  #    ID: ny4eiyiac4qfy7do4mgrydqyacoen652 To: 2348162522097
  #    ID: dxvtg2o9jhbqe4edifn026905st8mpz4 To: 2348162522102
  def generate_response
    if @numbers.size == 1
      @mock_response = 
      "ID: #{rand_string(32)}"  # Phone number is not given when it's the only one
    else
      @mock_response = 
         @numbers.map{|number| 
           "ID: #{rand_string(32)} To: #{number}"}.join("\n")
    end
  end
  
  def error_response
    "ERR: 105, INVALID DESTINATION ADDRESS"
  end

  def deliver(numbers=@numbers, body=@body)
#puts "****MockClickatellGateway#Deliver numbers=#{numbers}, body=#{body}"
    if numbers.is_a? String
      @numbers = numbers.gsub("+","").split(/,\s*/)
    else
      @numbers = numbers
    end
    @body = body
#    return (@mock_response || generate_response) # should be all that's needed, but doesn't work!
    if @mock_response.blank?
      @gateway_reply = generate_response
    else
      @gateway_reply = @mock_response
    end
    unless @options[:no_log]
      AppLog.create(:code => "SMS.sent.#{@gateway_name}", :description=>"to #{@numbers}: #{@body[0..30]}, resp=#{@gateway_reply}")
    end
    return @gateway_reply
  end  
end  # Of MockClickatellGateway


