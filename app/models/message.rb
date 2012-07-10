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

class Message < ActiveRecord::Base
  attr_accessible :body, :code, :confirm_time_limit, :expiration, :following_up, :from_id, :importance, :response_sime_limit, :retries, :retry, :send_email, :send_sms, :sms_only, :subject, :to_groups, :user_id
end
