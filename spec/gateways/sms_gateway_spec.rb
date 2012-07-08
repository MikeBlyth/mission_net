require 'spec_helper'
require 'sms_controller.rb'
require 'sms_gateway.rb'

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

