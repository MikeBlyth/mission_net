# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :country do
    sequence(:code) {|n| "country_#{n}" }
    name "Narnia"
    nationality "Narnian"
    include_in_selection true
  end
end
