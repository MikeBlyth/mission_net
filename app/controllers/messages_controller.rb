require 'sms_gateways_helper.rb'
include SmsGatewaysHelper

class MessagesController < ApplicationController
  load_and_authorize_resource
  
  active_scaffold :message do |config|
    config.list.columns = [:id, :created_at, :user, :body, :sms_only, :send_sms, :send_email, :to_groups, 
        :sent_messages, :importance, :status_summary]
    config.create.link.page = true 
    config.columns[:sent_messages].label = 'Sent to'
    config.columns[:importance].label = 'Imp'
    config.columns[:user].clear_link
    config.create.link.inline = false 
    config.update.link = false
    config.actions.exclude :update
    list.sorting = {:created_at => 'DESC'}
    config.action_links.add 'followup', :label => 'Follow up', :type => :member#, :inline=>false
  end

def create
  binding.pry
end

  def before_create_save(record)
    record.user = current_user if current_user
binding.pry  
  end

  def after_create_save(record)
    deliver_message(record) # This delivers the message "automatically" when created in this controller, 
  end
  
  def deliver_message(record)
    flash[:notice] = 'Message is being delivered'
    record.deliver  # Note that Message#deliver uses DelayedJob to run the actual delivery in the background.
  end

  # Send form to user for generating a follow-up on a given message
  def followup
    @id = params[:id]
    @original_msg = Message.find @id
    @record = Message.new
    @record.following_up = @id 
    @record.subject = "Following up on message #@id, \"#{@original_msg.subject}\"" 
    @record.sms_only = "f/u msg ##@id"
    @record.body = "This is Josie, the Joslink database gopher. I haven't seen a reply from you " +
        "showing that you received message ##{@id}. Could it be in your junk mail folder? We really " +
        "do want to be sure that you got this message so please make sure you've read it and then " +
        "just reply to this message or the original one."
  end
  
  # Use form from 'followup' to generate new message
  def followup_send
    @id = params[:id]  # Id of original message
    original_message = Message.find @id
    fu_message = Message.create(params[:record].merge(:following_up => @id))  # a new message object to send the follow up
    fu_message.members = original_message.members_not_responding
    fu_message.create_sent_messages # Sigh, we need this because contact list is generated upon _save_, and unless we
                                    # call create_sent_messages again (or use another tactic), the specified members
                                    # will not be included
#puts "**** fu_message.members =#{fu_message.members[0].last_name}, #{fu_message.members[0].primary_email}"
    deliver_message(fu_message)
    flash[:notice] = 'Follow up message sent'
    redirect_to messages_path
  end

end 
