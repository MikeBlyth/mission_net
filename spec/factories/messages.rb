# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    subject 'Subject line'
    body 'test message'
    sms_only 'This is the SMS line.'
    to_groups '7'  # use the id for the test group here
    retries 0
    send_email nil
    send_sms nil
  end
end
