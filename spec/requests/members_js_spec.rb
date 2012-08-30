require 'spec_helper'
require 'fake_web'
include ApplicationHelper

describe "Members" do
  before(:each) do
    FakeWeb.allow_net_connect = %r[^https?://(localhost|127\.0\.0\.1)]
  end      

  describe "showing/hiding columns:" do
    
    it 'starts with partial selection and toggles full selection' do
      member = integration_test_sign_in(:moderator) # This also puts member into "Group 1"
      page.should have_content "Click to show more columns"
      page.should_not have_content "Blood"
      click_link "Click to show more columns"
      page.should have_content "Blood"
      page.should have_content "Click to hide some columns"
      click_link "Click to hide some columns"
      page.should_not have_content "Blood"
    end

  end # showing/hiding columns:

  describe "wife selection" do

    it 'gives right choices for wife', :js => true do
      member = integration_test_sign_in(:moderator) # This also puts member into "Group 1"
      page.should have_content "Click to show more columns"
      wife = FactoryGirl.create(:member, :last_name => member.last_name, 
        :name => "#{member.last_name}, Alice", :first_name => "Alice" )
      nonwife_1 = FactoryGirl.create(:member)
      same_last_name_female = FactoryGirl.create(:member, :last_name => member.last_name)
      same_last_name_male = FactoryGirl.create(:member, :last_name => member.last_name,
        :wife => same_last_name_female) 
      member.update_attributes :name => "#{member.last_name}, Jonathan", 
        :first_name => "Jonathan"
      wife.reload.last_name.should == member.last_name
      visit members_path
      target = find "#as_members-update_column-#{member.id}-wife-cell"
      target.click
      select_list = find("#record_wife_#{member.id}")
puts "**** clicked on wife cell => options are #{select_list.text}"
      select_list.should have_content "Alice"
      select_list.should_not have_content nonwife_1.first_name
      select_list.should_not have_content same_last_name_female.first_name
    end
  end  # wife selection

  it 'allows inline editing', :js => true do
      FactoryGirl.create(:country, :name => 'Kenya')
      FactoryGirl.create(:country, :name => 'Narnia')
      FactoryGirl.create(:bloodtype, :full => 'A pos')
      FactoryGirl.create(:bloodtype, :full => 'B neg')
      city = FactoryGirl.create(:city)
      FactoryGirl.create(:location, :description => 'Cair Paravel', :city => city)
    member = integration_test_sign_in(:moderator) # This also puts member into "Group 1"
#puts "**** member.id=#{member.attributes}"
    update_values = {:name => "Hornbeck, Hannah", :first_name => "Hannah", :middle_name => "Dawn",
      :last_name => "Hornbeck", :phone_1 => '0805-555 5555', :phone_2 => '2347777777777',
      :email_1 => 'a@xyz.com', :email_2 => 'b@xyz.com', 
      :country => "Narnia", :location => 'Cair Paravel', :location_detail => 'dungeon',
      :comments => 'comments', :bloodtype => 'A pos',
      :arrival_date => '2012-05-24', :departure_date => '2013-05-23'}
    
    click_link "Click to show more columns"
    page.should have_content 'First name'

    # Fill in the editable text-boxes
    update_values.each do |key, value|
      target = find "#as_members-update_column-#{member.id}-#{key}-cell"
      target.click
      puts "**** key=#{key}"
      within target do
        if [:country, :location, :bloodtype].include? key
          select value
        else  
          fill_in "inplace_value", :with => value
        end
        click_button "Update"
      end
    end
    check "record[phone_private]"
    check "record[email_private]"
    check "record[in_country]"

#    target = find "#as_members-update_column-#{member.id}-name-cell"
#    target.click
#    within target do
#      fill_in "inplace_value", :with => "Doe, John"
#      click_button "Update"
#    end
    page.should have_no_selector('button.inplace_save')    
    member.reload
    update_values.each do |key, value|
puts "**** key=#{key}, value=#{value}, reload=#{member.send key}"
      saved_value = member.send(key)
      if key.to_s =~ /date/
        saved_value.should eq Date.parse(value)
      elsif key.to_s =~ /phone/
        saved_value.should eq std_phone(value)
      else
        saved_value.to_s.should eq value
      end
    end
    member.phone_private.should be_true
    member.email_private.should be_true
    member.in_country.should be_true
  end


end  
