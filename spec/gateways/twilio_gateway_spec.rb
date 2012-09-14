require 'spec_helper'
require 'sms_controller.rb'
require 'sms_gateway.rb'
require 'fakeweb.rb'

describe TwilioGateway do

  before(:each) do
    AppLog.stub(:create)
    FakeWeb.register_uri(:any, %r/http:\/\/api.twilio.com\//, :body => '{"message": "You tried to reach Twilio"}')
    FakeWeb.register_uri(:any, %r/https?:\/\/worker.*iron.io\//, :body => '{"message": "You tried to reach IronWorker"}')
    @phone_1, @phone_2 = '+2347777777777', '+2348888888888'
  end

  describe 'initialization' do

    it 'gives error when parameter is missing' do
      SiteSetting.stub(:twilio_account_sid).and_return(nil)  # Make User_name missing BEFORE .new
      @gateway = TwilioGateway.new
      @gateway.errors.should_not be_nil  # Will have errors even before saving 
      @gateway.errors[0].should match('account_sid')
    end

    it 'initializes successfully when needed parameters are present' do
      @gateway = TwilioGateway.new
      if @gateway.errors
        puts "*** Maybe the settings database has not been initialized."
        puts "*** Errors in gateway initialization may also be caused by 'cleaned' initialization"
        puts "*** parameters. Try restarting Spork before looking for other errors."
      end
      @gateway.errors.should be_nil
      @gateway.gateway_name.should == 'twilio'  # this is defined by TwilioGateway#initialize
    end
    
  end # initialization

  describe 'twilio-ruby @client connects to http' do
    it 'with basic authentication' do
#      HTTParty.should_receive(:get).with(test_uri) # i.e. without getting a session
#      HTTParty.should_not_receive(:get).with(/auth?/)
      @gateway = TwilioGateway.new
      @gateway.deliver(["99"],'Test message')
      rq = FakeWeb.last_request.body
      rq.should match /To=%2b99/i
      rq.should match /Body=Test\+message/
    end
  end

 
#  describe 'Queries status of a message' do
#    before(:each) do 
#      gateway_session_set('dummy')
#      @msg_id = 'abc'
#    end
#    
#    it 'Returns status when Twilio gives it' do
#      msg_id = "abcdefg12"
#      target = Regexp.new("querymsg\\?apimsgid=abcdefg12")  # 
#      @mock_reply.stub(:body).and_return "ID: #{msg_id} Status: 004"
#      HTTParty.should_receive(:get).with(target).and_return(@mock_reply)
#      @gateway.query(msg_id).should == MessagesHelper::MsgDelivered
#    end
#    
#    it 'Returns error message when Twilio rejects query' do
#      msg_id = "abcdefg12"
#      target = Regexp.new("querymsg\\?apimsgid=abcdefg12")  # 
#      error_message = "Err: 009, Some Error"
#      @mock_reply.stub(:body).and_return error_message
#      HTTParty.should_receive(:get).with(target).and_return(@mock_reply)
#      @gateway.query(msg_id).should == error_message
#    end
#    
#  end
      
  describe 'Deliver method sends messages--no delayed process' do
    before(:each) do
#      @client = Twilio::REST::Client.new "@account_sid", "auth_token"
      SiteSetting.stub(:twilio_background => '')
      @client = mock('Client').as_null_object
      Twilio::REST::Client.stub(:new => @client)
      @gateway = TwilioGateway.new
      @body = 'Test message'
    end

    describe 'for single phone number' do
      before(:each) do
        @phones = [@phone_1]
      end
      
      it 'calls @client to send message' do
        @client.should_receive(:create).with(hash_including(:from => SiteSetting.twilio_phone_number, :to => @phones[0], :body => @body))
        @gateway.deliver(@phones, @body)
      end

      it "adds + to a phone number" do
        @client.should_receive(:create).with(hash_including(:from => SiteSetting.twilio_phone_number, :to => @phones[0], :body => @body))
        @gateway.deliver(@phones[0][1..20], @body)
      end

# These need to be redone after deciding how to manage return status of gateway objects
#      it 'sets @gateway_reply variable' do
#        @gateway.deliver(@phones, 'test message')
#        @gateway.gateway_reply.should == @mock_reply
#      end        

#      it 'gives @gateway_reply as return value' do
#        @gateway.deliver(@phones, 'test message').should == @mock_reply
#      end        

    end # for single phone number

    describe 'for multiple phone numbers' do
      before(:each) do
        @phones = [@phone_1, @phone_2]
      end

      it 'calls @client to send message' do
        @client.should_receive(:create).with(hash_including(:from => SiteSetting.twilio_phone_number, :to => @phones[0], :body => @body))
        @client.should_receive(:create).with(hash_including(:to => @phones[1], :body => @body))
        @gateway.deliver(@phones, @body)
      end

#      it 'forms URI phone list from string' do
#        @gateway.deliver(@phones.join(', '), 'test message')
#        uri = @gateway.uri
#        uri.should match("to=2347777777777,2348888888888")
#      end

#      it 'sets @gateway_reply variable' do
#        @gateway.deliver(@phones, 'test message')
#        @gateway.gateway_reply.should == @mock_reply
#      end        

#      it 'gives @gateway_reply as return value' do
#        @gateway.deliver(@phones, 'test message').should == @mock_reply
#      end        

    end # for multiple phone number

    describe 'handles errors' do

      it 'logs an error' do
        @phones = [@phone_1]
        @client.should_receive(:create).and_raise
        AppLog.should_receive(:create).with(hash_including(:code => "SMS.error.twilio"))
        @gateway.deliver(@phones, @body)
      end

      it 'continues after an error' do
        @phones = [@phone_1, @phone_2 ]
        @client.should_receive(:create).and_raise
        @client.should_receive(:create).with(hash_including(:to => @phone_2))
        AppLog.should_receive(:create).with(hash_including(:code => "SMS.error.twilio"))
        AppLog.should_receive(:create).with(hash_including(:code => "SMS.sent.twilio"))
        @gateway.deliver(@phones, @body)
      end

    end # handles errors

    describe "calls message's update_status method" do
      let(:ok_status) {MessagesHelper::MsgSentToGateway}
      let(:bad_status) {MessagesHelper::MsgError}
      before(:each) do
        @phones = [@phone_1, @phone_2]
        @mock_msg = mock('Message').as_null_object
        Message.should_receive(:find_by_id).and_return(@mock_msg)
      end

      it 'as hash of statuses' do
        @mock_msg.should_receive(:update_sent_messages_w_status).with(
          {@phone_1=>{:status => ok_status}, @phone_2=>{:status => ok_status}}
          )
        @gateway.deliver(@phones, @body, 1)
      end

      it 'marking errors' do
        @mock_msg.should_receive(:update_sent_messages_w_status).with(
          {@phone_1=>{:status => bad_status}, @phone_2=>{:status => ok_status}}
          )
        @client.should_receive(:create).and_raise
        @client.should_receive(:create)
        @gateway.deliver(@phones, @body, 1)
      end
    end
              

  end # deliver method
  
  describe 'Deliver method sends messages--IronWorker' do
    before(:each) do
      SiteSetting.stub(:twilio_background => 'Ironworker')
      @gateway = TwilioGateway.new
      @iw_client = mock('IW_client').as_null_object
      IronWorkerNG::Client.stub(:new => @iw_client)
      @twilio_client = mock('Client', :to_s => 'MockClient').as_null_object
      Twilio::REST::Client.stub(:new => @twilio_client)
      @body = 'Test message'
    end

    describe 'for single phone number' do
      before(:each) do
        @phones = [@phone_1]
      end
      
      it 'calls Twilio directly' do
        @iw_client.should_not_receive(:create)
        @twilio_client.should_receive(:create)
        @gateway.deliver(@phones, @body)
      end

    end # for single phone number

    describe 'for multiple phone numbers' do
      before(:each) do
        @phones = [@phone_1, @phone_2]
      end

      it 'calls @client to send message' do
        @iw_client.should_receive(:create).with(
            "twilio_multi_worker",
            {:from => SiteSetting.twilio_phone_number, :numbers => @phones, :body => @body,
             :sid => SiteSetting.twilio_account_sid, :token => SiteSetting.twilio_auth_token
            }
          )
        @gateway.deliver(@phones, @body)
      end

    end # for multiple phone number
  end # deliver method --IronWorker
  
  describe 'Deliver method sends messages--DelayedJob' do
    before(:each) do
      SiteSetting.stub(:twilio_background => 'Delayed Job')
      @gateway = TwilioGateway.new
      @mock_heroku_connection = mock('Heroku connection')
      Heroku::API.stub(:new => @mock_heroku_connection)
      @twilio_client = mock('Client', :to_s => 'MockClient').as_null_object
      Twilio::REST::Client.stub(:new => @twilio_client)
      @body = 'Test message'
    end

    describe 'for single phone number' do
      before(:each) do
        @phones = [@phone_1]
      end
      
      it 'calls Twilio directly' do
        @mock_heroku_connection.should_not_receive(:post_ps_scale) # Don't start a worker
        @twilio_client.should_receive(:create)
        @gateway.deliver(@phones, @body)
        Delayed::Job.count.should == 0
      end
    end # for single phone number

    describe 'for multiple phone numbers' do
      before(:each) do
        @phones = [@phone_1, @phone_2]
      end

      it 'calls @client to send message' do
        @mock_heroku_connection.should_receive(:post_ps_scale) # Do start a worker
        @gateway.deliver(@phones, @body)
        Delayed::Job.count.should > 0
      end

    end # for multiple phone number
  end # deliver method --IronWorker
  
end
