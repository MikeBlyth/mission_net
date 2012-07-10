# == Schema Information
#
# Table name: messages
#
#  id                  :integer         not null, primary key
#  body                :text
#  from_id             :integer
#  code                :string(255)
#  confirm_time_limit  :integer
#  retries             :integer
#  retry_interval      :integer
#  expiration          :integer
#  response_time_limit :integer
#  importance          :integer
#  to_groups           :integer
#  send_email          :boolean
#  send_sms            :boolean
#  user_id             :integer
#  subject             :string(255)
#  sms_only            :string(255)
#  following_up        :integer
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#

include MessagesHelper

class Message < ActiveRecord::Base
  attr_accessible :body, :code, :confirm_time_limit, :expiration, :following_up, :from_id, :importance, :response_sime_limit, :retries, :retry, :send_email, :send_sms, :sms_only, :subject, :to_groups, :user_id
  has_many :sent_messages
  has_many :members, :through => :sent_messages  # May not be needed, 
  belongs_to :user
  validates_numericality_of :confirm_time_limit, :retries, :retry_interval, 
      :expiration, :response_time_limit, :importance, :allow_nil => true
  validates_presence_of :body, :if => 'send_email', :message=>'You need to write something in your message!'
  validates :to_groups, :presence => true, :unless => :following_up #:message=>'Select at least one group to receive message.', 
  validate :sending_medium
#  validate :sms_long_enough
  before_save :convert_groups_to_string
  after_save  :create_sent_messages   # each record represents this message for one recipient
  
  def after_initialize
    [:confirm_time_limit, :retries, :retry_interval, :expiration, :response_time_limit, :importance].each do |setting|
      self.send "#{setting}=", Settings.messages[setting] if (self.send setting).nil?
    end
  #  user = current_user 
  end   
  
  # Convert :to_groups=>["1", "2", "4"] or [1,2,4] to "1,2,4", as maybe 
  #    simpler than converting with YAML
  def convert_groups_to_string
    if self.to_groups.is_a? Array
      self.to_groups = self.to_groups.map {|g| g.to_i}.join(",")
    else
      self.to_groups = self.to_groups.to_s
    end
  end 

  def to_s
    "#{timestamp}: #{(body || sms_only)[0..50]}"
  end

  # (1) Add any Group members to the addressees (self.members) when groups are specified
  # (2) Generate @contact_info hash
  # (3) Remove any addressees who don't have the needed contact info, so that they won't count as
  #     errors in delivery and subject to automatic follow up.
  # This method is run automatically after save but also must be run if the addressees or sending methods
  # (email or SMS) are changed after the initial creation and before calling deliver.
  def create_sent_messages  
    target_members = self.members +
                     (Group.members_in_multiple_groups(to_groups_array) & # an array of users
                      Member.those_in_country)
    @contact_info = target_members.map {|m| {:member => m, :phone => m.primary_phone, :email => m.primary_email}}
    # Remove members from @contact_info if they do not have the needed contact info (phone or email)
    # We may want to keep track of those people since they _should_ get the message but we don't have
    # the necessary info to get it to them by the specified routes (phone or email).
    case
    when self.send_sms && !self.send_email
      @contact_info.delete_if {|c| c[:phone].nil?}
    when !self.send_sms && self.send_email
      @contact_info.delete_if {|c| c[:email].nil?}
    when self.send_sms && self.send_email
      @contact_info.delete_if {|c| c[:email].nil? && c[:phone].nil?}
    end
    self.members = @contact_info.map {|c| c[:member]}
  end
  
  # Send the messages -- done by creating the sent_message objects, one for each member
  #   members_in_multiple_groups(array) is all the members belonging to these groups and
  #   to_groups_array is the array form of the destination groups for this message
  def deliver(params={})
    puts "**** Message#deliver" if params[:verbose]
#puts "**** Message#deliver response_time_limit=#{self.response_time_limit}"
    save! if self.new_record?
    deliver_email() if send_email
    deliver_sms(:sms_gateway=>params[:sms_gateway] || default_sms_gateway) if send_sms
  end
  
  # Array of members who have not yet responded to this message
  def members_not_responding
    memb = sent_messages.map { |sm| (sm.msg_status || -1) < MessagesHelper::MsgDelivered ? sm.member : nil }.compact
  end

  # Send messages to those not responding or not receiving the SMS message.
  # This should be clarified. Currently, with "if m.msg_status < MessagesHelper::MsgDelivered", 
  # all SMS are considered OK (not needing follow up) if it's shown that they were delivered. That is, 
  # it seems this will not send a follow up to those who have received the message but not responded. 
  # We may want to distinguish two groups: (1) those who have not received message (error status, pending, etc) and
  # (2) those who have not responded. (1) would be useful to overcome transient errors, while (2) would only be used
  # when we have specifically requested a response.
  def send_followup(params={})
    @contact_info = sent_messages.map do |sm|  # including only sent_messages w/o response
      m = sm.member  # member to whom this message was sent
      if m.msg_status < MessagesHelper::MsgDelivered
        {:member => m, :phone => m.primary_phone, :email => m.primary_email} 
      else
        nil
      end
    end
    deliver_email if send_email
    deliver_sms(:sms_gateway=>params[:sms_gateway]) if send_sms
  end    
    

  def timestamp
    t = created_at.in_time_zone(SIM::Application.config.time_zone)
    hour = t.hour
    if (0..9).include?(hour) || (13..21).include?(hour)
      str = (t.strftime('%e%b')+t.strftime('%l')[1]+t.strftime(':%M%P'))[0..9]
    else
      str = t.strftime('%e%b%l%M%P')[0..9]
    end
    str = str[1..9] if str[0] == ' '   # gives us one extra character :-)
    return str
  end
  
  def to_groups_array
    to_groups.split(",").map{|g| g.to_i} if to_groups
  end

  def sent_messages_pending
    sent_messages.map {|m| m if m.msg_status == MessagesHelper::MsgSentToGateway || 
                               m.msg_status == MessagesHelper::MsgPending}.compact
  end                               
  
  def sent_messages_errors
    sent_messages.map  {|m| m if m.msg_status == MessagesHelper::MsgError || m.msg_status.nil?}.compact
  end                               
  
  def sent_messages_delivered
    sent_messages.map {|m| m if m.msg_status == MessagesHelper::MsgDelivered}.compact
  end                               
  
  def sent_messages_replied
    sent_messages.map {|m| m if m.msg_status == MessagesHelper::MsgResponseReceived}.compact
  end                               
  
  def current_status
#puts "**** current_status"
    errors = sent_messages_errors
    errors_names = errors.map{|m| m.member.shorter_name}.join(', ')
    pending = sent_messages_pending
    pending_names = pending.map{|m| m.member.shorter_name}.join(', ')
    delivered = sent_messages_delivered
    delivered_names = delivered.map{|m| m.member.shorter_name}.join(', ')
    replied = sent_messages_replied
    replied_names = replied.map{|m| m.member.shorter_name}.join(', ')

    status = {:errors=>errors.size, :errors_names => errors_names,
              :pending=>pending.size, :pending_names => pending_names,
              :delivered=>delivered.size, :delivered_names => delivered_names,
              :replied=>replied.size, :replied_names => replied_names
              }
  end

  # Do whatever needed to record that 'member' has responded to this message
  # Do not update a record that already has been marked with MessagesHelper::MsgResponseReceived
  def process_response(params={})
    member=params[:member]
    text=params[:text]
    mode=params[:mode] # (SMS or email)
#puts "**** process_response: self.id=#{self.id}, member=#{member}, text=#{text}"
#puts "**** sent_messages = #{self.sent_messages}"
    sent_message = self.sent_messages.detect {|m| m.member_id == member.id}
#puts "**** sent_message=#{sent_message}"
    if sent_message && (sent_message.msg_status.nil? || sent_message.msg_status < MessagesHelper::MsgResponseReceived ) 
      sent_message.update_attributes(:msg_status=>MessagesHelper::MsgResponseReceived,
          :confirmation_message=>text, :confirmed_time => Time.now, :confirmed_mode  => mode)
    else
      AppLog.create(:code => "Message.response", 
        :description=>"Message#process_response called for message #{self.id}, member=#{member}, but corresponding sent_message record was not found", :severity=>'error')
    end
  end

#private

  # ToDo: clean up this mess and just give Notifier the Message object!
  def deliver_email
#puts "**** deliver_email: emails=#{emails}"
    emails = @contact_info.map {|c| c[:email]}.compact.uniq
    self.subject ||= 'Message from SIM Nigeria'
    id_for_reply = self.following_up || id  # a follow-up message uses id of the original msg
#puts "**** Messages#deliver_email response_time_limit=#{response_time_limit}"
    outgoing = Notifier.send_group_message(:recipients=>emails, :content=>self.body, 
        :subject => subject, :id => id_for_reply , :response_time_limit => response_time_limit, 
        :bcc => true, :following_up => following_up) # send using bcc:, not to:
raise "send_email with nil email produced" if outgoing.nil?
    outgoing.deliver
    # Mark all as being sent, but only if they have an email address
    # This is terribly inefficient ... need to find a way to use a single SQL statement
    sent_messages.each do |sm| 
      sm.update_attributes(:msg_status => MsgSentToGateway) if sm.member.primary_email
    end
  end
  
  def assemble_sms
    id_for_reply = self.following_up || id  # a follow-up message uses id of the original msg
    resp_tag = (following_up || response_time_limit) ? " !#{id_for_reply}" : ''
    self.sms_only = sms_only[0..(159-self.timestamp.size-resp_tag.size)] + resp_tag + ' ' + self.timestamp
  end

  # Deliver text messages to an array of phone members, recording their acceptance at the gateway
  # ToDo: refactor so we don't need to get member-phone number correspondance twice
  def deliver_sms(params)
#puts "**** Message#deliver_sms; params=#{params}"
    sms_gateway = params[:sms_gateway]
    phone_number_array = @contact_info.map {|c| c[:phone]}.compact.uniq
    phone_numbers = phone_number_array.join(',')
    assemble_sms()
#puts "**** sms_gateway.deliver #{sms_gateway} w #{phone_numbers}: #{sms_only}"
    #******* CONNECT TO GATEWAY AND DELIVER MESSAGES 
    gateway_reply = 
      sms_gateway.deliver(phone_numbers, sms_only)
#puts "**** gateway_reply=#{gateway_reply}"
    #******* PROCESS GATEWAY REPLY (INITIAL STATUSES OF SENT MESSAGES)  
    gtw_msg_id = nil
    if phone_number_array.size == 1
      #   SINGLE PHONE NUMBER   
      if gateway_reply =~ /ID: (\w+)/
        gtw_msg_id = $1
        gtw_msg_id = gateway_reply[4..99]        # Temporary workaround as $1 doesn't work on Heroku
        msg_status = MessagesHelper::MsgSentToGateway
      else
        gtw_msg_id = gateway_reply  # Will include error message
        msg_status = MessagesHelper::MsgError
      end
      # Mark the message to this member as being sent
      self.sent_messages[0].update_attributes(:gateway_message_id => gtw_msg_id, 
          :msg_status => msg_status)
    else
      # MULTIPLE PHONE NUMBERS
      # Get the Clickatell reply and parse into array of hash like {:id=>'asebi9xxke...', :phone => '2345552228372'}
#puts "**** gateway_reply=#{gateway_reply}"
      msg_statuses = gateway_reply.split("\n").map do |s|
        if s =~ /ID:\s+(\w+)\s+To:\s+([0-9]+)/
          {:id => $1, :phone => $2}    
        else
          {:id => nil, :phone => nil, :error => s}
        end
      end
      # Make array to associate members with their numbers
      @member_phones = self.members.map {|m| {:phone => m.primary_phone, :member => m} }
      # Update the sent_message records to indicate which have been accepted at Gateway  
      msg_statuses.each do |s|
#puts "**** s[:id]=#{s[:id]}, s[:phone]=#{s[:phone]}"
        if s[:id] && s[:phone]
          # Find the right member by matching phone numbers
          member = @member_phones.find{|m| m[:phone]==s[:phone]}[:member]
          # Find the right sent_message by matching member & message
          sent_message = SentMessage.where(:member_id=>member.id, :message_id=>self.id).first
          # Update the sent_message
          sent_message.update_attributes(
              :gateway_message_id => s[:id], 
              :msg_status=> MessagesHelper::MsgSentToGateway
          )
        end
      end
    # Any sent_messages not now marked with gateway_message_id and msg_status must have errors
    sent_messages.each do |m| 
      m.update_attributes(:msg_status=> MessagesHelper::MsgError) if m.msg_status.nil?
    end
    end
  end
 
  def sending_medium
    unless send_sms or send_email
      errors.add(:base,'Must select a message type (email, SMS, etc.)')
    end
  end
  
  def sms_long_enough
    if send_sms && (sms_only.nil? || sms_only.size < 40 )
      errors.add(:sms_only, 'too short, maybe you should add a favorite quote :-)')
    end
  end
end
