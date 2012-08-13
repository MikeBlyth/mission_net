include BasePermissionsHelper

# == Schema Information
#
# Table name: sent_messages
#
#  id                   :integer         not null, primary key
#  message_id           :integer
#  member_id            :integer
#  msg_status           :integer
#  confirmed_time       :datetime
#  delivery_modes       :string(255)
#  confirmed_mode       :string(255)
#  confirmation_message :string(255)
#  attempts             :integer
#  gateway_message_id   :string(255)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  phone                :string(255)
#  email                :string(255)
#

# == Schema Information
#
# Table name: sent_messages
#
#  id                   :integer         not null, primary key
#  message_id           :integer
#  member_id            :integer
#  msg_status           :integer
#  confirmed_time       :datetime
#  delivery_modes       :string(255)
#  confirmed_mode       :string(255)
#  confirmation_message :string(255)
#  attempts             :integer
#  gateway_message_id   :string(255)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  phone                :string(255)
#  email                :string(255)
#
require 'mail'

class SentMessage < ActiveRecord::Base
  attr_accessible :msg_status, :confirmed_time, :delivery_modes, :confirmed_mode, :confirmation_message, :attempts, :gateway_message_id
  belongs_to :message
  belongs_to :member
  before_create :add_contacts
  
  def add_contacts
    self.phone = member.primary_phone
    self.email = member.primary_email
  end

  def to_s
    member ? member.full_name_short : '*'
  end

  def set_confirmed_time  
    self.confirmed_time = Time.now
  end


end
