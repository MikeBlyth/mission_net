include MessagesHelper
include SmsGatewaysHelper

describe 'id tag helper (message_id_tag)' do
  # Of course these will have to be changed if you change the format of the tags
  
  it 'generates id_tag for body' do
    message_id_tag(:id=>500, :action=>:generate, :location=>:body).should == "#500"
  end
  
  it 'generates id_tag for head' do
    message_id_tag(:id=>500, :action=>:generate, :location=>:subject).should == "(JosAlerts message #500)"
  end

  it 'generates confirming tag for explanation (in body)' do
    message_id_tag(:id=>500, :action=>:confirm_tag).should == "!500"
  end
    
  it 'finds id_tag in subject' do
    message_id_tag(:action=>:find, :location=>:subject,
      :text => "Re: Important security message (JosAlerts message #501)").should == 501
  end
  
  it 'returns nil when finding id_tag in subject' do
    message_id_tag(:action=>:find, :location=>:subject,
      :text => "Re: Important security message ").should == nil
  end
  
  it 'finds id_tag in body (w "confirm #nnn")' do
    message_id_tag(:action=>:find, :location=>:body,
      :text => "lkj lkj l confirm #501").should == 501
  end
  
  it 'finds id_tag in body (w "!nnn")' do
    message_id_tag(:action=>:find, :location=>:body,
      :text => "lkj lkj l !501").should == 501
  end

  it 'returns nil when not finding id_tag in body' do
    message_id_tag(:action=>:find, :location=>:body,
      :text => "Re: Important security message ").should == nil
  end
end  
  
describe 'find_message_id_tag' do
  
  it 'finds tag in header' do
    find_message_id_tag(:subject=>"Re: Security (JosAlerts message #501)", :body => "Just some stuff").
      should == 501
  end

  it 'finds tag in body' do
    find_message_id_tag(:subject=>"Confirming", :body => "Just some stuff plus !501").should == 501
  end

  it 'returns nil if no tag anywhere' do
    find_message_id_tag(:subject=>"Confirming", :body => "Just some stuff ").should be_nil
  end
  
  it 'returns nil if no text is empty' do
    find_message_id_tag().should be_nil
  end
  
  it 'returns nil for exclamation point without following digits' do
    find_message_id_tag(:subject=>"Confirming", :body => "Just some stuff! ").should be_nil
  end
  
end # find_message_id_tag

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


