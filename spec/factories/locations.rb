# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    name "MyString"
    state "MyString"
    city "MyString"
    lga "MyString"
    gps_latitude ""
    gps_longitude ""
  end
end
