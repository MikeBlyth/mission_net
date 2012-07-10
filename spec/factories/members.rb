# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :member do
    sequence(:last_name) {|n| "LastNameA_#{n}" }
    sequence(:first_name) {|n| "Person_#{n}" }
    name {"#{first_name} #{last_name}"}
    middle_name "MyString"
    phone_1 "Phone 1"
    phone_2 "Phone 2"
    email_1 "email_1"
    email_2 "email_2"
    location_id 1
    location_detail "MyString"
    arrival_date "2012-06-02"
    departure_date "2012-06-02"
    receive_sms true
    receive_email true
  end
end
