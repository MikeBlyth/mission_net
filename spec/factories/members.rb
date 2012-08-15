# == Schema Information
#
# Table name: members
#
#  id                      :integer         not null, primary key
#  last_name               :string(255)
#  first_name              :string(255)
#  middle_name             :string(255)
#  name                    :string(255)
#  country_id              :integer
#  emergency_contact_phone :string(255)
#  emergency_contact_email :string(255)
#  emergency_contact_name  :string(255)
#  phone_1                 :string(255)
#  phone_2                 :string(255)
#  email_1                 :string(255)
#  email_2                 :string(255)
#  location_id             :integer
#  location_detail         :string(255)
#  arrival_date            :date
#  departure_date          :date
#  receive_sms             :boolean
#  receive_email           :boolean
#  blood_donor             :boolean
#  bloodtype_id            :integer
#  created_at              :datetime        not null
#  updated_at              :datetime        not null
#  phone_private           :boolean
#  email_private           :boolean
#  in_country              :boolean
#  comments                :string(255)
#  short_name              :string(255)
#

FactoryGirl.define do
  factory :member do
    sequence(:last_name) {|n| "LastNameA_#{n}" }
    sequence(:first_name) {|n| "First_#{n}" }
    name {"#{first_name} #{last_name}"}
    middle_name "Midly"
    short_name "Shorty"
    phone_1 "2348034444444"
    phone_2 "2348034444444"
    email_1 "shorty@test.com"
    email_2 "midly@test.com"
    in_country true
    location_detail "Headquarters"
    arrival_date "2012-06-02"
    departure_date "2012-06-02"
    receive_sms true
    receive_email true
    blood_donor true
    phone_private false
    email_private false
    comments "Some comments"
  end
end
