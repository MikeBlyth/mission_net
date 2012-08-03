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
#  blood_type_id           :integer
#  created_at              :datetime        not null
#  updated_at              :datetime        not null
#

require 'spec_helper'
require 'sim_test_helper'
include SimTestHelper

describe Member do

  describe 'does basic validation' do
    before(:each) do
      @member = FactoryGirl.create(:member)
    end    
    
    it "can make a factory member" do
    end

    it "is valid with valid attributes" do
      @member.should be_valid
    end

  end # basic validation

  describe "names: " do
    before(:each) do
      @member = Member.new
      @member.first_name = 'Katarina'
      @member.middle_name = 'Saunders'
      @member.last_name = 'Patterson'
     end  
    
  end # names

  describe 'finds members by name' do
    before(:each) do
      @member = FactoryGirl.create(:member)
    end

    it 'return empty array if name not found' do
      Member.find_with_name('stranger').should == []
    end

    it 'returns empty array if name blank' do
      Member.find_with_name('').should == []
    end

    it 'returns empty array if name nil' do
      Member.find_with_name(nil).should == []
    end

    it 'finds simple name' do  # searching for ONE of last name, first name, full name
      Member.find_with_name(@member.first_name).should == [@member]
      Member.find_with_name(@member.last_name).should == [@member]
      Member.find_with_name(@member.name).should == [@member]
    end

    it 'finds "last_name, first_name"' do  # when this is different from stored full name (#name)
      @member.update_attribute(:name,"xxxx")  # since we're not relying on this
      Member.find_with_name("#{@member.last_name}, #{@member.first_name}").should == [@member]
    end
      
    it 'finds "last_name, initial"' do  
      Member.find_with_name("#{@member.last_name}, #{@member.first_name[0]}").should == [@member]
    end
      
    it 'finds "first_name last_name"' do  
      Member.find_with_name("#{@member.first_name} #{@member.last_name}").should == [@member]
    end
      
    it 'finds "beginning_of_first_name beginning_of_last_name"' do  
      Member.find_with_name("#{@member.first_name[0..2]} #{@member.last_name[0..1]}").should == [@member]
    end
      
    it 'finds "beginning_of_first_name"' do  
      Member.find_with_name("#{@member.first_name[0..2]}").should == [@member]
    end
      
    it 'finds "beginning_of_last_name"' do  
      Member.find_with_name("#{@member.last_name[0..2]}").should == [@member]
    end

    it 'finds both members with first name' do
      same_first = FactoryGirl.create(:member, :last_name=>'different', :first_name=>@member.first_name)
      Member.find_with_name("#{@member.first_name}").should include(@member)
      Member.find_with_name("#{@member.first_name}").should include(same_first)
    end
     
  end # finds members by name

  describe 'finds members by email' do
    it 'using email_1' do
      email = 'sample@test.com'
      member = FactoryGirl.create(:member, :email_1 => email)
      Member.find_by_email(email).should == [member]
    end

    it 'using email_2' do
      email = 'sample@test.com'
      member = FactoryGirl.create(:member, :email_2 => email)
      Member.find_by_email(email).should == [member]
    end
    
    it 'when two share same address' do
      email = 'sample@test.com'
      member = FactoryGirl.create(:member, :email_1 => 'something else', :email_2 => email)
      member2 = FactoryGirl.create(:member, :email_1 => email)
      unrelated = FactoryGirl.create(:member, :email_1 => 'watermelon')
      Member.find_by_email(email).should include member
      Member.find_by_email(email).should include member2
      Member.find_by_email(email).should_not include unrelated
    end
      
  end
  
  describe 'finds members by phone' do
    it 'using phone_1' do
      phone = 'sample@test.com'
      member = FactoryGirl.create(:member, :phone_1 => phone)
      Member.find_by_phone(phone).should == [member]
    end

    it 'using phone_2' do
      phone = 'sample@test.com'
      member = FactoryGirl.create(:member, :phone_2 => phone)
      Member.find_by_phone(phone).should == [member]
    end
    
    it 'when two share same number' do
      phone = 'sample@test.com'
      member = FactoryGirl.create(:member, :phone_1 => 'something else', :phone_2 => phone)
      member2 = FactoryGirl.create(:member, :phone_1 => phone)
      unrelated = FactoryGirl.create(:member, :phone_1 => 'watermelon')
      Member.find_by_phone(phone).should include member
      Member.find_by_phone(phone).should include member2
      Member.find_by_phone(phone).should_not include unrelated
    end
      
  end
  
  describe 'contact information' do
    before(:each) do
      @member = FactoryGirl.build(:member)
    end
  
    describe 'contact_summary hash' do

      it 'includes phone and email' do
        summary = @member.contact_summary
        summary['Phone'].should match @member.phone_1
        summary['Phone'].should match @member.phone_2
        summary['Email'].should match @member.email_1
        summary['Email'].should match @member.email_2
      end  

      it 'hides private phone number' do
        @member.phone_private = true
        @member.contact_summary['Phone'].should_not match @member.phone_1
        @member.contact_summary['Phone'].should_not match @member.phone_2
      end

      it 'hides private email address' do
        @member.email_private = true
        @member.contact_summary['Email'].should_not match @member.email_1
        @member.contact_summary['Email'].should_not match @member.email_2
      end

      it 'shows private phone number if override_private is selected' do
        @member.phone_private = true
        @member.contact_summary(:override_private=>true)['Phone'].should match @member.phone_1
        @member.contact_summary(:override_private=>true)['Phone'].should match @member.phone_2
        @member.contact_summary(:override_private=>true)['Phone'].should match 'private'
      end

      it 'shows private email if override_private is selected' do
        @member.email_private = true
        @member.contact_summary(:override_private=>true)['Email'].should match @member.email_1
        @member.contact_summary(:override_private=>true)['Email'].should match @member.email_2
        @member.contact_summary(:override_private=>true)['Email'].should match 'private'
      end

    end # 'contact_summary hash'

    describe 'contact_summary_text' do
      it 'includes phone and email' do
        summary = @member.contact_summary_text
        summary.should match @member.phone_1
        summary.should match @member.email_1
      end
    end # 'contact_summary_text'
  end   # contact information 

  describe 'finds those in country' do
    
    it 'checks the "in country" field' do
      @member = FactoryGirl.create(:member, :in_country => true)
      @member_ooc = FactoryGirl.create(:member, :in_country => false)
      Member.those_in_country.should == [@member]
    end
  end
      
  describe 'export' do
    before(:each) do
      @member = FactoryGirl.build(:member)
      Member.stub(:all).and_return([@member])
    end      

    it 'makes csv object' do
#      @on_field = Factory.build(:status) # "field" is true by default
      csv = Member.export ['last_name',]
      csv.should match(@member.last_name)
    end

    # Todo: Refactor next two into tests just for csv_helper or export
    it 'gracefully ignores unknown column names' do
      csv = Member.export ['last_name', 'xxxxxzzzz']
      csv.should match(@member.last_name)
    end

    it 'handles case with no column names' do
      # This test will pass regardless of what export returns; we just want to know that it doesn't crash
      csv = Member.export [] 
    end
      
  end # Export
  
  describe 'Calculating in-country status' do
    before(:each) do
      @member = FactoryGirl.build_stubbed(:member, :in_country=>true, :departure_date => nil, :arrival_date => nil)
    end
    
    describe 'when dates frame an in-country period' do
      it 'returns False when in-country interval is exceeded' do
        @member.departure_date = Date.today - 2.days
        @member.arrival_date = Date.today - 20.days
        @member.calculate_in_country_status.should == [false, nil, nil]
      end
        
      it 'returns true when today falls during in-country interval' do
        @member.departure_date = Date.today + 2.days
        @member.arrival_date = Date.today - 20.days
        @member.calculate_in_country_status.should == [true, @member.departure_date, @member.arrival_date]
      end
        
      it "doesn't change anything when in-country interval is in the future" do
        @member.departure_date = Date.today + 20.days
        @member.arrival_date = Date.today + 2.days
        @member.calculate_in_country_status.should == [true, @member.departure_date, @member.arrival_date]
      end
    end # when dates frame an in-country period
      
    describe 'when dates frame an out-of-country period' do
      it 'returns true when out-of-country interval is exceeded' do
        @member.arrival_date = Date.today - 2.days
        @member.departure_date = Date.today - 20.days
        @member.calculate_in_country_status.should == [true, nil, @member.arrival_date]
      end
        
      it 'returns false when today falls during out-of-country interval' do
        @member.arrival_date = Date.today + 2.days
        @member.departure_date = Date.today - 20.days
        @member.calculate_in_country_status.should == [false, @member.departure_date, @member.arrival_date]
      end
        
      it "doesn't change anything when out-of-country interval is in the future" do
        @member.arrival_date = Date.today + 20.days
        @member.departure_date = Date.today + 2.days
        @member.in_country = false  # Should remain false even though logically person is in the country
        @member.calculate_in_country_status.should == [false, @member.departure_date, @member.arrival_date]
      end
    end # when dates frame an in-country period
      
    describe 'when only departure date is given' do
      it 'returns no change when departure date is in the future' do
        @member.in_country = false  # Should remain false if set, even though logically person is in the country
        @member.departure_date = Date.today + 20.days
        @member.calculate_in_country_status.should == [false, @member.departure_date, nil]
      end
        
      it 'returns false when departure date is in the past' do
        @member.departure_date = Date.today - 20.days
        @member.calculate_in_country_status.should == [false, @member.departure_date, nil]
      end
    end # when only departure date is given
        
    describe 'when only arrival date is given' do
      it 'returns no change when arrival date is in the future' do
        @member.in_country = true  # Should remain true if set, even though logically person is not yet in the country
        @member.arrival_date = Date.today + 20.days
        @member.calculate_in_country_status.should == [true, nil, @member.arrival_date]
      end
        
      it 'returns true when arrival date is in the past' do
        @member.arrival_date = Date.today - 20.days
        @member.calculate_in_country_status.should == [true, nil, @member.arrival_date]
      end
        
    end # when only arrival date is given
      
  end

end

