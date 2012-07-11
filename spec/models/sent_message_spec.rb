require 'spec_helper'

describe SentMessage do
  pending "add some examples to (or delete) #{__FILE__}"
end
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

