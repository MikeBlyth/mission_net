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
#  to_groups           :string(255)
#  send_email          :boolean
#  send_sms            :boolean
#  user_id             :integer
#  subject             :string(255)
#  sms_only            :string(255)
#  following_up        :integer
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#  keywords            :string(255)
#  news_update         :boolean
#  private             :boolean
#

include MessagesHelper

#require 'ironworker_twilio_gateway.rb'

class Message < ActiveRecord::Base
  attr_accessible :body, :code, :confirm_time_limit, :expiration, :following_up, :from_id, 
      :importance, :response_sime_limit, :retries, :retry, :send_email, :send_sms, :sms_only, 
      :subject, :to_groups, :user_id, :keywords, :private, :news_update
  attr_reader :phones, :emails
  has_many :sent_messages
  has_many :members, :through => :sent_messages 
  belongs_to :user, :class_name => 'Member'
  validates_numericality_of :confirm_time_limit, :retries, :retry_interval, 
      :expiration, :response_time_limit, :importance, :allow_nil => true
  validates_presence_of :body, :if => 'send_email || news_update', :message=>'You need to write something in your message!'
  validate :check_recipients
  validate :sending_medium
  before_save :convert_groups_to_string
  after_save  :create_sent_messages   # each record represents this message for one recipient
  
  after_initialize do |message|
    [:confirm_time_limit, :retries, :retry_interval, :expiration, :response_time_limit, :importance].each do |setting|
      message.send "#{setting}=", Settings.messages[setting] if (message.send setting).nil?
    end
  #  user = current_user 
    @phones = nil
    @emails = nil
  end   
  
  # ********** Class Methods ************************
  def self.news_updates(options={})
    key_search_expr = options[:keyword].blank? ? "%" : "%#{options[:keyword]}%" 
    updates = self.where(:news_update => true).
      where("created_at + expiration * interval '1 hours' > ?", Time.now ).
      where("keywords LIKE ? OR subject LIKE ? OR body LIKE ? OR sms_only LIKE ?", key_search_expr,key_search_expr, key_search_expr, key_search_expr).
      order('updated_at DESC').limit(options[:limit])
  end
  
  # This is not an automatic length checker! It needs to be changed if you change the length of the timestamp.
  def self.timestamp_length
    Date.today.day < 10 ? 9 : 10   # timestamp is shorter if day of month is one digit, like 9Mar1252p 
  end

  # ********** End Class Methods ************************

  # Convert :to_groups=>["1", "2", "4"] or [1,2,4] to "1,2,4", as maybe 
  #    simpler than converting with YAML
  # ToDo this probably isn't necessary as Rails should serialize the array. Try getting rid of some of it
  def convert_groups_to_string   
    if self.to_groups.is_a? Array
      self.to_groups = self.to_groups.map do |g| 
        i = g.to_i
        Group.exists?(i) ? i : nil
      end.compact.join(",")
    else
      self.to_groups = self.to_groups.to_s
    end
  end 

  def to_s
    "[#{id || 'new'}] #{timestamp || '--' }: #{(body || sms_only)[0..50]}"
  end

  def insert_contact_info(target_members)
    @emails = target_members.map {|c| c.primary_email}.compact.uniq
    @phones = target_members.map {|c| c.primary_phone}.compact.uniq
  end

  # (1) Add any Group members to the addressees (self.members) when groups are specified
  # (2) Generate @contact_info hash
  # (3) Remove any addressees who don't have the needed contact info, so that they won't count as
  #     errors in delivery and subject to automatic follow up.
  # This method is run automatically after save but also must be run if the addressees or sending methods
  # (email or SMS) are changed after the initial creation and before calling deliver.
  def create_sent_messages 
#puts "**** create_sent_messages"     
    target_members = (self.members +
                     (Group.members_in_multiple_groups(to_groups_array) & # an array of users
                      Member.those_in_country)).uniq.compact
    # Remove members from @contact_info if they do not have the needed contact info (phone or email)
    # We may want to keep track of those people since they _should_ get the message but we don't have
    # the necessary info to get it to them by the specified routes (phone or email).
    case
    when self.send_sms && !self.send_email
      target_members.delete_if {|c| c.primary_phone.nil?}
    when !self.send_sms && self.send_email
      target_members.delete_if {|c| c.primary_email.nil?}
    when self.send_sms && self.send_email
      target_members.delete_if {|c| c.primary_email.nil? && c.primary_phone.nil?}
    end
    insert_contact_info(target_members)
    self.members.destroy_all # force recreate the join table entries, to be sure contact info is fresh
    self.members = target_members
#target_members.each {|m| puts "**** #{m.name}\t#{m.phone_1}\t#{m.email_1}"}
  end
  
  # Send the messages 
  def deliver(options={})
    puts "**** Message#deliver" if options[:verbose]
#puts "**** Message#deliver response_time_limit=#{self.response_time_limit}"
    save! if self.new_record?
    deliver_email() if send_email 
    deliver_sms(:sms_gateway => options[:sms_gateway]) if send_sms # Note that if gateway is nil, default_sms_gateway will be used
  end
  
  # Array of members who have not yet responded to this message
  # (select all of this messages members whose sent_message status is less than "delivered")
  def members_not_responding
    sent_messages.select{|sm| (sm.msg_status || -99) < MessagesHelper::MsgDelivered}.map {|sm| sm.member}
  end

  # Send messages to those not responding or not receiving the SMS message.
  # This should be clarified. Currently, with "if m.msg_status < MessagesHelper::MsgDelivered", 
  # all SMS are considered OK (not needing follow up) if it's shown that they were delivered. That is, 
  # it seems this will not send a follow up to those who have received the message but not responded. 
  # We may want to distinguish two groups: (1) those who have not received message (error status, pending, etc) and
  # (2) those who have not responded. (1) would be useful to overcome transient errors, while (2) would only be used
  # when we have specifically requested a response.
  def send_followup(options={})
    self.members = members_not_responding
    deliver_email if send_email
    deliver_sms(:sms_gateway=>options[:sms_gateway]) if send_sms
  end    
    
  # Create compact timestamp string from current time or the record's created_at time.
  # If you change the length of the timestamp, be sure to adjust the self.timestamp_length method above!
  def timestamp(current=false)
    if current # Use current time rather than record's time.
      t = Time.now
    else
      return nil if created_at.nil?
      t = created_at.in_time_zone(Joslink::Application.config.time_zone)
    end
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
    sent_messages.select {|m|  m.msg_status == MessagesHelper::MsgSentToGateway || 
                               m.msg_status == MessagesHelper::MsgPending}
  end                               
  
  def sent_messages_errors
    sent_messages.select {|m| m.msg_status == MessagesHelper::MsgError || m.msg_status.nil?}
  end                               
  
  def sent_messages_delivered
    sent_messages.select {|m| m.msg_status == MessagesHelper::MsgDelivered}
  end                               
  
  def sent_messages_replied
    sent_messages.select {|m| m.msg_status == MessagesHelper::MsgResponseReceived}
  end                               
  
  def member_names_string(sm_array)
    sm_array.map{|sm| sm.member.nil? ? nil : sm.member.shorter_name}.compact.join(', ')
  end

  def current_status
#puts "**** current_status"
    errors = sent_messages_errors
    errors_names = member_names_string(errors)
    pending = sent_messages_pending
    pending_names = member_names_string(pending)
    delivered = sent_messages_delivered
    delivered_names = member_names_string(delivered)
    replied = sent_messages_replied
    replied_names = member_names_string(replied)

    status = {:errors=>errors.size, :errors_names => errors_names,
              :pending=>pending.size, :pending_names => pending_names,
              :delivered=>delivered.size, :delivered_names => delivered_names,
              :replied=>replied.size, :replied_names => replied_names
              }
  end

  # Do whatever needed to record that 'member' has responded to this message
  # Do not update a record that already has been marked with MessagesHelper::MsgResponseReceived
  def process_response(options={})
    member=options[:member]
    text=options[:text]
    mode=options[:mode] # (SMS or email)
#puts "**** process_response: self.id=#{self.id}, member=#{member}, text=#{text}"
#puts "**** sent_messages = #{self.sent_messages}"
    sent_message = self.sent_messages.detect {|m| m.member_id == member.id}
#puts "**** sent_message=#{sent_message}"
    if sent_message && (sent_message.msg_status.nil? || sent_message.msg_status < MessagesHelper::MsgResponseReceived ) 
      sent_message.update_attributes(:msg_status=>MessagesHelper::MsgResponseReceived,
          :confirmation_message=>text, :confirmed_time => Time.now, :confirmed_mode  => mode)
    elsif sent_message.nil?
      AppLog.create(:code => "Message.response", 
        :description=>"Message#process_response called for message #{self.id}, member=#{member}, but corresponding sent_message record was not found", :severity=>'error')
    end
  end

#private

  # ToDo: clean up this mess and just give Notifier the Message object!
  def deliver_email(options={})
    @emails ||= options[:emails] || sent_messages.map {|sm| sm.email}.compact.uniq
    @emails = @emails.split(',') if @emails.is_a? String # Strangely, arrays respond to split in this app, so can't use "respond_to?"
    if @emails.empty?
puts "**** Trying to deliver message ##{self.id} but no email addresses found."  
      AppLog.create(:code => 'Message.deliver_email', :severity=> 'warning', 
         :description => "Attempting to send message ##{self.id} but no email addresses found")
      return
    end
    self.subject ||= 'Message from Joslink/Josalerts'
    id_for_reply = self.following_up || id  # a follow-up message uses id of the original msg
#puts "**** Messages#deliver_email response_time_limit=#{response_time_limit}"
    outgoing = Notifier.send_group_message(:recipients=>@emails, :content=>self.body, 
        :subject => subject, :id => id_for_reply , :response_time_limit => response_time_limit, 
        :bcc => true, :following_up => following_up) # send using bcc:, not to:
#puts "**** Message#deliver_email outgoing=#{outgoing}"
    outgoing.deliver
    # Mark all as being sent, but only if they have an email address
    # This is terribly inefficient ... need to find a way to use a single SQL statement
    sent_messages.each do |sm| 
      sm.update_attributes(:msg_status => MessagesHelper::MsgSentToGateway) if sm.email
    end
  end
  
  # Add the message id if needed for reply, the signature and the time stamp
  def assemble_sms
    id_for_reply = self.following_up || id  # a follow-up message uses id of the original msg
    resp_tag = (following_up || response_time_limit) ? " !#{id_for_reply}" : ''
    self.sms_only = sms_only[0..(158-self.timestamp.size-resp_tag.size)] + resp_tag + ' ' + self.timestamp
  end

  def update_sent_messages_w_status(gateway_reply)
#puts "**** update_sent_messages_w_status: gateway_reply=#{gateway_reply}"
    gateway_reply.each do |number, result|
      sent_messages.find_by_phone(number).
           update_attributes(:gateway_message_id => result[:sms_id] || result[:error], 
              :msg_status=> result[:status] )
    end
  end
 
  # Deliver text messages to an array of phone members, recording their acceptance at the gateway
  # If options[:phone_numbers] exists, it overrides the SentMessages records (so can send to a specific member)
  # If options[:news_update] exists, the SentMessages are not updated with the status 
  #    (but since we're replying to an incoming number, it should work)
  # ToDo: refactor so we don't need to get member-phone number correspondance twice
  def deliver_sms(options={})
#puts "**** Message#deliver_sms; options=#{options}"
    sms_gateway = options[:sms_gateway] || SmsGateway.default_sms_gateway
    @phones ||= options[:phone_numbers] || sent_messages.map {|sm| sm.phone}.compact.uniq
    @phones = @phones.split(',') if @phones.is_a? String 
    if @phones.empty?
      AppLog.create(:code => 'Message.deliver_sms', :severity=> 'warning', 
         :description => "Attempting to send SMS for message ##{self.id} but no phone numbers found")
      return
    end
    assemble_sms()
#puts "**** sms_gateway.deliver #{sms_gateway} w #{phone_numbers}: #{sms_only}"
    #******* CONNECT TO GATEWAY AND DELIVER MESSAGES 
    gateway_reply = sms_gateway.deliver(@phones, sms_only)
#puts "**** sms_gateway=#{sms_gateway}"
#puts "**** gateway_reply=#{gateway_reply}"
    #******* PROCESS GATEWAY REPLY (INITIAL STATUSES OF SENT MESSAGES)  
    update_sent_messages_w_status(gateway_reply) if options[:news_update].nil? && gateway_reply # The IF is there just to make testing simpler.
                                                                   # In production, a reply will always be present?
  end
  
  def check_recipients
    unless to_groups || following_up || !(send_sms || send_email)
      errors.add(:to_groups, 'Please select one or more groups to receive this message')
    end
  end
 
  def sending_medium
    unless send_sms or send_email or news_update
      errors.add(:base,'Must select a message type (email, SMS, etc.) or "news update"')
    end
  end
  
end
