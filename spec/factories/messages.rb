# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    body "MyText"
    from_id 1
    code "MyString"
    confirm_time_limit 1
    retries 1
    retry_interval 5
    expiration 1
    response_time_limit 1
    importance 1
    to_groups 1
    send_email false
    send_sms false
    user_id 1
    subject "MyString"
    sms_only "MyString"
    following_up 1
  end
end
