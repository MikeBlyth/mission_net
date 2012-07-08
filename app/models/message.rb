class Message < ActiveRecord::Base
  attr_accessible :body, :code, :confirm_time_limit, :expiration, :following_up, :from_id, :importance, :response_sime_limit, :retries, :retry, :send_email, :send_sms, :sms_only, :subject, :to_groups, :user_id
end
