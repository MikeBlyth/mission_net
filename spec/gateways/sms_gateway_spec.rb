require 'spec_helper'
require 'sms_controller.rb'
require 'sms_gateway.rb'
require 'mock_clickatell_gateway.rb'

describe SmsGateway do

  it 'initializes successfully' do
    SmsGateway.new
  end

  it 'stores number and body when specified in send' do
    gateway = SmsGateway.new
    gateway.deliver('+2347777777777', 'test message')
    gateway.numbers.should == '+2347777777777'
    gateway.body.should == 'test message'
  end
end

describe 'default_sms_gateway from from SiteSetting.gateway_name' do
  before(:each) do
    silence_warnings do
      @old_clickatell_gateway = ClickatellGateway
      @old_mock_gateway = MockClickatellGateway
      ClickatellGateway = mock('ClickatellGateway')
      MockClickatellGateway = mock('MockClickatellGateway')
    end
  end
  
  after(:each) do
     silence_warnings do
      ClickatellGateway = @old_clickatell_gateway
      MockClickatellGateway = @old_mock_gateway
    end
  end
     
  it 'creates new gateway object in production mode' do
    Rails.stub(:env => 'production')
    SiteSetting.stub(:default_outgoing_sms_gateway => 'clickatell')
    ClickatellGateway.should_receive(:new)
    SmsGateway.default_sms_gateway
  end
  
  it 'creates new mock gateway object in test mode' do
    Rails.stub(:env => 'test')
    SiteSetting.stub(:default_outgoing_sms_gateway => 'clickatell')
    MockClickatellGateway.should_receive(:new)
    ClickatellGateway.should_not_receive(:new)
    SmsGateway.default_sms_gateway
  end
  
  it 'creates instance of user-defined mock gateway' do
    MockUserdefinedGateway = mock('MockUserdefinedGateway')
    Rails.stub(:env => 'test')
    SiteSetting.stub(:default_outgoing_sms_gateway => 'userdefined')
    MockUserdefinedGateway.should_receive(:new)
    MockClickatellGateway.should_not_receive(:new)
    SmsGateway.default_sms_gateway
  end
  
  it 'creates new MockClickatellGateway in test mode if no mock for requested gateway' do
    Rails.stub(:env => 'test')
    SiteSetting.stub(:default_outgoing_sms_gateway => 'something')
    MockClickatellGateway.should_receive(:new)
    ClickatellGateway.should_not_receive(:new)
    SmsGateway.default_sms_gateway
  end
  
end # default_sms_gateway

