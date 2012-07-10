class SentMessagesController < ApplicationController
  active_scaffold :sent_message do |config|
    config.list.columns = [:id, :message_id, :member, :msg_status, :confirmed_time, :confirmed_mode, :confirmation_message]
 #   config.subform.columns.exclude :message
    config.list.empty_field_text = '--'
    list.sorting = {:message_id => 'DESC', :confirmed_time => 'DESC'}
  #  config.delete.link = false
    config.show.link = false
    config.actions.exclude :update
# These cause some error in ActiveScaffold -- debug when there is the occasion.
#    config.columns[:msg_status].form_ui = :select 
#    config.columns[:msg_status].options[:options] = 
#      [['Error', MessagesHelper::MsgError], 
#      ['Sent to Gateway', MessagesHelper::MsgSentToGateway],
#      ['Pending', MessagesHelper::MsgPending],
#      ['Delivered', MessagesHelper::MsgDelivered],
#      ['Responded', MessagesHelper::MsgResponseReceived] ]    
#    config.columns[:confirmed_time].inplace_edit = true
#    config.columns[:confirmed_mode].options[:options] = [['email', 'email'], ['sms', 'sms']]
#    config.columns[:confirmed_mode].form_ui = :select 
#    config.columns[:confirmation_message].inplace_edit = true
  end

#  include AuthenticationHelper
#skip_authorize_resource :only => :update_status_clickatell

  def update_status_clickatell
#puts "Clickatell status call with params=#{params}"
    parsed = ClickatellGateway.parse_status_params(params)  # Let Gateway be responsible for understanding the params
#puts "**** parsed=#{parsed}"
    @sent_message = SentMessage.find_by_gateway_message_id parsed[:gateway_msg_id]  # The message whose status is being reported
#puts "**** @sent_message=#{@sent_message}, parsed[:updates]=#{parsed[:updates]} "
    @sent_message.update_attributes(parsed[:updates]) if @sent_message
    AppLog.create(:code => "SMS.clickatell.update", :description=>"params=#{params}")
    render :text => "Success", :status => 200
  end
end 
