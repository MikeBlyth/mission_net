require 'twilio-ruby'
puts "Running TwilioMultiWorker..."

puts "Connecting to Twilio..."
client = Twilio::REST::Client.new(params['sid'], params['token'])
puts "Connected."

puts "Sending messages..."
from = params['from']
body = params['body']
numbers = params['numbers'].map {|n| n[0] == '+' ? n : '+' + n}
errors = [] # To make status hash
numbers.each do |number|
  begin
    client.account.sms.messages.create(
        :from => from,
        :to => number,
        :body => body
    )
  rescue  # twilio-ruby indicates failed phone number by raising exception Twilio::REST::RequestError
    errors << number
    puts "Failed with phone number #{number}"
  end
end

puts "Finished processing TwilioSMSWorker."
