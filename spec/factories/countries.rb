# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :country do
    code "MyString"
    name "MyString"
    nationality "MyString"
    include_in_selection "MyString"
  end
end
