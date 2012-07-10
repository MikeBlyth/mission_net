# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
    sequence(:group_name) {|n| "Group #{n}" }
    sequence(:abbrev) {|n| "group#{n}"}
    parent_group_id 1
    primary false
  end
end
