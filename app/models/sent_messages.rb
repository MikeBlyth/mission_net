class SentMessages < ActiveRecord::Base
  attr_accessible :attempts, :confirmation_message, :confirmed_mode, :confirmed_time, :delivery_modes, :gateway_message_id, :member_id, :message_id, :msg_status
end
