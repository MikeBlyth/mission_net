require 'spec_helper'
require 'mock_clickatell_gateway'
require 'messages_test_helper'
include MessagesTestHelper
include SimTestHelper
require 'iron_worker_ng'

describe MessagesController do

  before(:each) do
    test_sign_in_fast
    @gateway = mock('Gateway')
    SmsGateway.stub(:default_sms_gateway => @gateway)
    SiteSetting.stub(:default_sms_outgoing_gateway => 'Clickatell')
  end

  def mock_message(stubs={})
    @mock_message ||= mock_model(Message, stubs).as_null_object
  end

  describe 'New' do
    
    it 'sets defaults from Settings' do
      get :new
      settings_with_default = [:confirm_time_limit, :retries, :retry_interval, :expiration, 
                               :response_time_limit, :importance]
      settings_with_default.each {|setting| assigns(:record)[setting].should == Settings.messages[setting]}
    end

  end

  describe 'Create' do
    before(:each) do
#      @user = FactoryGirl.build(:member)
#      @user.stub(:is_administrator => true)
#      controller.stub(:current_user=>@user)
      @user = test_sign_in
    end
    
    it 'does nothing' do
      @user.role.should == :administrator
    end
      
    it 'admin can create message' do
      controller.stub(:deliver_message=>true)   # to skip the delivery
      lambda{post :create, :record => {:body=>"test", :to_groups=>["1", '2'], :send_sms=>true, :send_email=>false}}.
        should change{Message.count}.by(1)
    end
    
    it 'member can create message' do
      test_sign_in(:member)
      controller.stub(:deliver_message=>true)   # to skip the delivery
      lambda{post :create, :record => {:body=>"test", :to_groups=>["1", '2'], :send_sms=>true, :send_email=>false}}.
        should change{Message.count}.by(1)
    end
    
    it 'adds user name to record' do
      controller.stub(:deliver_message=>true)   # to skip the delivery
      post :create, :record => {:body=>"test", :to_groups=>["1", '2'], :send_sms=>true, :send_email=>false}
      Message.first.user_id.should == @user.id  # Remember if using mocks that @user itself will not be saved
    end
    
    it 'sends the message' do
      @members = members_w_contacts(1, false)
      @gateway.should_receive :deliver
      post :create, :record => {:sms_only=>"test "*10, :to_groups=>["1", '2'], :send_sms=>true}
    end  
    
    it 'counts empty response_time_limit as nil' do
      @members = members_w_contacts(1, false)
      @gateway.should_receive :deliver
      post :create, :record => {:sms_only=>"test "*10, :to_groups=>["1", '2'], 
        :response_time_limit=>'', :send_sms=>true}
      Message.first.response_time_limit.should == nil
    end
  end
  
  describe 'Follow up' do
    before(:each) do
      @original_msg = FactoryGirl.create(:message, :subject => "Original message subject", 
        :send_email => true)
    end
    
    it 'sends form for generating follow up message' do
      get :followup, :id => @original_msg.id
      assigns(:original_msg).should eq @original_msg
      record = assigns(:record)
      original_id = @original_msg.id
      record.following_up.should eq original_id
      record.subject.should eq I18n.t('messages.followup.subject_line', :id => original_id, :subject => @original_msg.subject)
      record.sms_only.should eq I18n.t('messages.followup.sms_line', :id => original_id, :subject => @original_msg.subject)
      record.sms_only.should eq I18n.t('messages.followup.sms_line', :id => original_id, :subject => @original_msg.subject)
      record.body.should eq I18n.t('messages.followup.body_content', :id => original_id, :subject => @original_msg.subject)
    end

    it 'sends the follow-up msg to those not responding to first msg' do  # Would be nice to do this w/o accessing DB!
      @fast_responder = FactoryGirl.create(:member)  # handy if not most efficient way to make a member with a contact
      @slow_responder = FactoryGirl.create(:member)
      @original_msg.members << [@fast_responder, @slow_responder]
      @fast_responder.sent_messages.first.update_attributes(:msg_status => MessagesHelper::MsgResponseReceived)
      @original_msg.members.should =~ [@fast_responder, @slow_responder]
      @gateway.should_receive :deliver
      Notifier.should_receive(:send_group_message).
          with(hash_including(:recipients => [@slow_responder.primary_email],
                              :id => @original_msg.id)).
          and_return(mock('MailMessage').as_null_object)
      get :followup_send, :id => @original_msg.id, 
        :record => {:body=>"reminder",  :sms_only => '#'*50, :send_email => true, :send_sms => true}
      Message.last.members.should == [@slow_responder]  # i.e. message will be sent to @slow and not @fast
    end    

  end                        
end
