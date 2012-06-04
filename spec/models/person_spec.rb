require 'spec_helper'

describe Person do
  pending "add some examples to (or delete) #{__FILE__}"

  it 'does not save person with duplicate name' do
    @person = Person.create(:last_name=>'Jones', :first_name=>'Greg')
    @person = Person.new(:last_name=>'Jones', :first_name=>'Greg')
    @person.should_not be_valid
    @person.errors[:name][0].should match('exist')
  end

end
# == Schema Information
#
# Table name: people
#
#  id                      :integer         not null, primary key
#  family_id               :integer
#  last_name               :string(255)
#  first_name              :string(255)
#  middle_name             :string(255)
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
#  blood_type_id           :integer
#  created_at              :datetime        not null
#  updated_at              :datetime        not null
#

