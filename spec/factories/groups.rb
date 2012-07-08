# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
    name "MyString"
    parent_group_id 1
    description "MyString"
    primary false
  end
end
