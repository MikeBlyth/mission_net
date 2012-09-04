require 'spec_helper'

describe SentMessagesController do

  it 'updates a sent-message on callback by Clickatell' do
# The next line should NOT be necessary, but skip_authorization_check in the controller
# fails when this test is preceded by a test of an ActiveScaffold controller.
puts "**** Starting"
#DatabaseCleaner.strategy = :truncation
#DatabaseCleaner.clean
test_sign_in_fast
    member = FactoryGirl.build_stubbed(:member)
    sm = FactoryGirl.create(:sent_message, :member => member)
    dummy_status = 2
    update_time = DateTime.now.utc
    AppLog.should_receive(:create)
    # decoded status is what ClickatellGateway returns using the raw parameters received from Clickatell
    decoded_status = {
      :gateway_msg_id => sm.gateway_message_id, 
      :updates => {:msg_status=>dummy_status, :confirmed_time=> update_time }  # These are the changes applied to sent_message
      }
    ClickatellGateway.stub(:parse_status_params => decoded_status)
puts "**** Calling update"
    get :update_status_clickatell, {:params_do_not_matter_for_this_test => true}
    sm.reload.msg_status.should eq dummy_status
    sm.reload.confirmed_time.to_s(:short).should eq update_time.to_s(:short)
    response.status.should eq 200
  end

end
