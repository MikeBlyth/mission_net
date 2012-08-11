# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :location do
    description "Friendly Guesthouse"
    city_id "1"
    code 'FGH'
  end
end
