require 'spec_helper'
require 'sms_controller.rb'
require 'sms_gateway.rb'
require 'fakeweb.rb'


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
    @phone_1, @phone_2 = '2347777777777', '2348888888888'
    @phones = [@phone_1]
    @body = 'Test message'
    @mock_reply = mock('gatewayReply', :body=>'')  # Remember to add stubs for body when something expected
    @gateway = ClickatellGateway.new
    FakeWeb.allow_net_connect = false
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
        puts "*** Maybe the settings database has not been initialized."
        puts "*** Errors in gateway initialization may also be caused by 'cleaned' initialization"
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
        @reply = 'ID: ABCDEF'
        FakeWeb.register_uri(:any, %r|http://api\.clickatell\.com/http/|, :body => @reply)
        FakeWeb.allow_net_connect = false
        @gateway = ClickatellGateway.new
#        @httyparty = HTTParty
        gateway_session_set('abcdef')
#        silence_warnings{HTTParty = mock('HTTParty')}
        @mock_reply.stub(:body).and_return("ID: ABCDEF")
#        HTTParty.stub(:get).and_return @mock_reply
      end
#      after(:each) do
#        silence_warnings{ HTTParty = @httyparty }  # Restore normal 
#      end

    describe 'for single phone number' do
      # Maybe this before(:each) should be refactored? It's funny to have the test going on there, but it's not
      # DRY if we put the mock & message expectation in the individual tests ...

      it 'forms URI properly' do
        @gateway.deliver(@phones, @body)
        uri = @gateway.uri
        uri.should match("to=#{phone_1}")
        uri.should match("text=#{URI.escape(@body)}")
      end

      it "forms URI phone number string when number doesn't start with a +" do
        @gateway.deliver('1234567890', @body)
        @gateway.uri.should match("to=1234567890")
      end

    end # for single phone number

    describe 'for multiple phone numbers' do
      before(:each) do
        @phones = [@phone_1.with_plus, @phone_2.with_plus]
      end

      it 'forms URI properly' do
        @gateway.deliver(@phones, @body)
        uri = @gateway.uri
        uri.should match("to=#{phone_1},#{phone_2}")
        uri.should match("text=#{URI.escape(@body)}")
      end

      it 'forms URI phone list from string' do
        @gateway.deliver(@phones.join(', '), @body)
        uri = @gateway.uri
        uri.should match("to=#{phone_1},#{phone_2}")
      end

     end # for multiple phone number

    describe 'returns status list' do
      before(:each) do
        @phones = [@phone_1, @phone_2]
      end

      it 'as hash of statuses' do
        FakeWeb.register_uri(:any, %r|http://api\.clickatell\.com/http/|, 
          :body => "ID: XXX To: #{@phone_1}\nID: YYY To: #{@phone_2}")
        response = @gateway.deliver(@phones, @body)
puts "**** response=#{response}"
        response[@phones[0]].should == {:status=> MessagesHelper::MsgSentToGateway, :sms_id => 'XXX'}
        response[@phones[1]].should == {:status=> MessagesHelper::MsgSentToGateway, :sms_id => 'YYY'}
      end

      it 'marking errors' do
        @client.should_receive(:create).and_raise
        @client.should_receive(:create)
        response = @gateway.deliver(@phones, @body)
        response[@phones[0]].should == MessagesHelper::MsgError
        response[@phones[1]].should == MessagesHelper::MsgSentToGateway
      end
    end # returns status list
              
  end # deliver method


end
