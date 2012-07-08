# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sent_message, :class => 'SentMessages' do
    message_id 1
    member_id 1
    msg_status 1
    confirmed_time "2012-07-08 22:30:08"
    delivery_modes "MyString"
    confirmed_mode "MyString"
    confirmation_message "MyString"
    attempts 1
    gateway_message_id "MyString"
  end
end
