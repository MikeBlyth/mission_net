require 'spec_helper'

describe Person do
  before(:each) do
    @person = Person.new(:last_name=>'Jones', :first_name=>'Greg', :middle_name=>'x')
  end

  describe 'Name checking' do 
    it 'person without first name is invalid' do
      @person.first_name = ''
      @person.should_not be_valid
    end

    it 'person without last name is invalid' do
      @person.first_name = ''
      @person.should_not be_valid
    end

    it 'person with unique name is valid' do
      @person.save
      Person.new(:last_name=>'Jones', :first_name=>'Greg', :middle_name=>'V').should be_valid
    end

    it 'person with duplicate name is invalid' do
      @person.save
      @person2 = Person.new(:last_name=>'Jones', :first_name=>'Greg', :middle_name=>'x')
      @person2.should_not be_valid
      @person2.errors[:name][0].should match('exist')
    end
  end
  
  describe 'and families' do

    it 'after save creates a new family if one is not defined' do 
      lambda{@person.save}.should change(Family, :count).by(1)
      family = @person.family
      family.should_not be_nil
      family.head.should == @person
    end

    it 'uses existing family if one is defined' do
      @person.family_id = 1
      lambda{@person.save}.should_not change(Family, :count)
    end

    it 'should not delete a person who is head of family' do
      @person.save
      family = @person.family
      lambda{@person.destroy}.should_not change(Person, :count)
    end

    it 'should delete a person who is not head of family' do
      @person.save
      @person2 = FactoryGirl.create(:person, :family=>@person.family)
      lambda{@person2.destroy}.should change(Person, :count).by(-1)
    end

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

