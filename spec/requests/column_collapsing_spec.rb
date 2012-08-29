require 'spec_helper'
require 'fake_web'

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
    
  end
end  
