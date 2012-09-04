# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sent_message, :class => 'SentMessage' do
    message_id 1
    member_id 1
    msg_status 1
    confirmed_time "2012-07-08 22:30:08"
    delivery_modes "DeliveryModes"
    confirmed_mode "ConfMode"
    confirmation_message "ConfMsg"
    attempts 1
    gateway_message_id "GatewayMsgID"
  end
end
