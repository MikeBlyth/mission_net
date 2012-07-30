require 'iron_worker_ng'

client = IronWorkerNG::Client.new

test_numbers = ['2348168522097']

client.tasks.create('twilio_multi', {:sid => SiteSetting.twilio_account_sid, :token => SiteSetting.twilio_auth_token, 
        :from => SiteSetting.twilio_phone_number, :numbers => test_numbers, :body => 'Testing Twilio multi worker' })


