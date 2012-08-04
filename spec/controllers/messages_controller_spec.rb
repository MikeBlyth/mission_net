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
    
    it 'setup' do
#      binding.pry  
    end

    it 'sets defaults from Settings' do
      get :new
      settings_with_default = [:confirm_time_limit, :retries, :retry_interval, :expiration, 
                               :response_time_limit, :importance]
      settings_with_default.each {|setting| assigns(:record)[setting].should == Settings.messages[setting]}
    end
  end

  describe 'Create' do
    before(:each) do
#      @old_applog = AppLog
#      silence_warnings { AppLog = mock('AppLog').as_null_object }
      controller.stub(:current_user=>FactoryGirl.build(:member))
    end
#    after(:each) do
#      silence_warnings { AppLog = @old_applog }
#    end
      
    it 'adds user name to record' do
      controller.stub(:deliver_message=>true)
      post :create, :record => {:body=>"test", :to_groups=>["1", '2'], :send_sms=>true, :send_email=>false}
      Message.first.user.should == controller.current_user
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

    it 'sends the follow-up msg to those not responding to first msg' do  # Would be nice to do this w/o accessing DB!
      @original_msg = FactoryGirl.create(:message,:send_email => true)
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
