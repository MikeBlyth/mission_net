# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
    group_name "MyString"
    parent_group_id 1
    abbrev "MyString"
    primary false
  end
end
