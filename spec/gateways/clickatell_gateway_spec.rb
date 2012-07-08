require 'spec_helper'
require 'sms_controller.rb'
require 'sms_gateway.rb'

describe ClickatellGateway do

def gateway_session
   @gateway.instance_variable_get(:@session)
end

def gateway_session_set(session)
   @gateway.instance_variable_set(:@session, session)
end

def gateway_uri_set(uri)
   @gateway.instance_variable_set(:@uri, uri)
end

  before(:each) do
    @phones = ['+2347777777777']
    @mock_reply = mock('gatewayReply', :body=>'')  # Remember to add stubs for body when something expected
    @gateway = ClickatellGateway.new
  end

  describe 'when needed parameters are missing' do

    it 'gives error when parameter is missing' do
      SiteSetting.stub(:clickatell_user_name).and_return(nil)  # Make User_name missing BEFORE .new
      @gateway = ClickatellGateway.new
      @gateway.errors.should_not be_nil  # Will have errors even before saving 
      @gateway.errors[0].should match('user_name')
    end

  end # when needed parameters are missing
  
  describe 'when needed parameters are present' do

    it 'initializes successfully' do
      if @gateway.errors
        puts "*** Errors in gateway initialization may be caused by 'cleaned' initialization"
        puts "*** parameters. Try restarting Spork before looking for other errors."
      end
      @gateway.errors.should be_nil
      @gateway.gateway_name.should == 'clickatell'  # this is defined by ClickatellGateway#initialize
    end
    
  end # 'when needed parameters are present

  describe 'Handles sessions:' do
    before(:each) do
      @session = 'eixktixyiis32kx00l'
    end
    
    it 'gets a session' do 
      @mock_reply.stub(:body).and_return("OK: #@session")
      HTTParty.stub_chain(:get).and_return(@mock_reply)
      @gateway.get_session.should == @session
      @gateway.instance_variable_get(:@session).should == @session
    end

    it 'returns error' do
      @mock_reply.stub(:body).and_return('reply', :body=>'Err: 001, Authentication Failed')
      HTTParty.stub(:get).and_return(@mock_reply)
      @gateway.get_session.should == @mock_reply.body
      gateway_session.should be_nil
    end
  end # Handles sessions
  
  describe 'Connects to gateway' do
    before(:each) do
      @session_reply = mock('SessionReply', :body=>'OK: uoiusdjweoijlskdfjowei7789',
                :session => 'uoiusdjweoijlskdfjowei7789')
     end
    
    it 'with basic authentication' do
      test_uri = "http://etc/?password=and_so_on"
      gateway_uri_set(test_uri)
      HTTParty.should_receive(:get).with(test_uri) # i.e. without getting a session
      HTTParty.should_not_receive(:get).with(/auth?/)
      @gateway.call_gateway
      gateway_session.should be_nil
    end

    it 'with a valid session' do
      test_uri = "http://etc/do_something?blahblahblah"
      gateway_uri_set(test_uri)
      gateway_session_set('dummy')
      @mock_reply.stub(:body).and_return('Fine')   # Anything but an error message
      HTTParty.should_receive(:get).with(test_uri+"&session_id=dummy").and_return(@mock_reply)
      @gateway.call_gateway
    end
    
    it 'with an expired session, getting a new one' do
      test_uri = "http://etc/do_something?blahblahblah"
      gateway_uri_set(test_uri)
      gateway_session_set('dummy')
      # Clickatell replies with a "Session Expired" message
      @mock_reply.stub(:body).and_return("Err: #{ClickatellGateway::ExpiredSessionCode}, Session expired")
      HTTParty.should_receive(:get).with(test_uri+"&session_id=dummy").and_return(@mock_reply)
      HTTParty.should_receive(:get).with(/auth\?/).and_return(@session_reply) # Clickatell gives new session
      # then we should send the request again, with the new session
      HTTParty.should_receive(:get).with(test_uri+"&session_id=#{@session_reply.session}").and_return(@mock_reply)
      @gateway.call_gateway
    end
  end
  
  describe 'Queries status of a message' do
    before(:each) do 
      gateway_session_set('dummy')
      @msg_id = 'abc'
    end
    
    it 'Returns status when Clickatell gives it' do
      msg_id = "abcdefg12"
      target = Regexp.new("querymsg\\?apimsgid=abcdefg12")  # 
      @mock_reply.stub(:body).and_return "ID: #{msg_id} Status: 004"
      HTTParty.should_receive(:get).with(target).and_return(@mock_reply)
      @gateway.query(msg_id).should == MessagesHelper::MsgDelivered
    end
    
    it 'Returns error message when Clickatell rejects query' do
      msg_id = "abcdefg12"
      target = Regexp.new("querymsg\\?apimsgid=abcdefg12")  # 
      error_message = "Err: 009, Some Error"
      @mock_reply.stub(:body).and_return error_message
      HTTParty.should_receive(:get).with(target).and_return(@mock_reply)
      @gateway.query(msg_id).should == error_message
    end
    
  end
      
  describe 'Deliver method sends messages' do
      before(:each) do
        @gateway = ClickatellGateway.new
        @httyparty = HTTParty
        gateway_session_set('abcdef')
        silence_warnings{HTTParty = mock('HTTParty')}
        @mock_reply.stub(:body).and_return("ID: ABCDEF")
        HTTParty.stub(:get).and_return @mock_reply
      end
      after(:each) do
        silence_warnings{ HTTParty = @httyparty }  # Restore normal 
      end

    describe 'for single phone number' do
      # Maybe this before(:each) should be refactored? It's funny to have the test going on there, but it's not
      # DRY if we put the mock & message expectation in the individual tests ...

      it 'forms URI properly' do
        HTTParty.should_receive(:get).with(/session_id=abcdef/)
        @gateway.deliver(@phones, 'test message')
        uri = @gateway.uri
        uri.should match("to=2347777777777")
        uri.should match("text=#{URI.escape('test message')}")
      end

      it "forms URI phone number string when number doesn't start with a +" do
        @gateway.deliver('1234567890', 'test message')
        @gateway.uri.should match("to=1234567890")
      end

      it 'sets @gateway_reply variable' do
        @gateway.deliver(@phones, 'test message')
        @gateway.gateway_reply.should == @mock_reply
      end        

      it 'gives @gateway_reply as return value' do
        @gateway.deliver(@phones, 'test message').should == @mock_reply
      end        

    end # for single phone number

    describe 'for multiple phone numbers' do
      before(:each) do
        @phones = ['+2347777777777', '+2348888888888']
      end

      it 'forms URI properly' do
       HTTParty.should_receive(:get).with(/session_id=abcdef/)
        @gateway.deliver(@phones, 'test message')
        uri = @gateway.uri
        uri.should match("to=2347777777777,2348888888888")
        uri.should match("text=#{URI.escape('test message')}")
      end

      it 'forms URI phone list from string' do
        @gateway.deliver(@phones.join(', '), 'test message')
        uri = @gateway.uri
        uri.should match("to=2347777777777,2348888888888")
      end

      it 'sets @gateway_reply variable' do
        @gateway.deliver(@phones, 'test message')
        @gateway.gateway_reply.should == @mock_reply
      end        

      it 'gives @gateway_reply as return value' do
        @gateway.deliver(@phones, 'test message').should == @mock_reply
      end        

    end # for multiple phone number

  end # deliver method
end
