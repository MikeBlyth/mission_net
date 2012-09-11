class SentMessagesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :authorize
  skip_authorization_check

  active_scaffold :sent_message do |config|
    config.list.columns = [:id, :message_id, :member, :msg_status, :phone, :confirmed_time, :confirmed_mode, :confirmation_message]
 #   config.subform.columns.exclude :message
    config.list.empty_field_text = '--'
    list.sorting = {:message_id => 'DESC', :confirmed_time => 'DESC'}
  #  config.delete.link = false
    config.show.link = false
    config.actions.exclude :update, :create
  end

  def update_status_clickatell
#puts "Clickatell status call with params=#{params}"
    parsed = ClickatellGateway.parse_status_params(params)  # Let Gateway be responsible for understanding the params
#puts "**** parsed=#{parsed}"
    @sent_message = SentMessage.find_by_gateway_message_id parsed[:gateway_msg_id]  # The message whose status is being reported
#puts "**** @sent_message=#{@sent_message}, parsed[:updates]=#{parsed[:updates]} "
    @sent_message.update_attributes(parsed[:updates]) if @sent_message
    AppLog.create(:code => "SMS.clickatell.update", :description=>"params=#{params}")
    render :text => I18n.t("success"), :status => 200
  end
end 
