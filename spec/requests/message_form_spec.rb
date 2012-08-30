require 'spec_helper'
require 'fake_web'
include ApplicationHelper

describe 'Message form' do

  it 'displays selection list of groups', :js => true do
    admin_group = FactoryGirl.create(:group, :group_name => 'Administrators', :administrator => true)
    members_group = FactoryGirl.create(:group, :group_name => 'Members', :member => true)
  
    member = integration_test_sign_in(:moderator) # This also puts member into "Group 1"
    page.should have_content "Click to show more columns"
    click_link "Create new message"
    page.should have_content "Create Message"
    fill_in "record_sms_only", :with => "X" * 50
    counter = find(".counter").text
    counter =~ /[\d]+/
    counter.to_i.should be < 100  # Characters remaining should be decreased since we put in 50*"X"
    # Check that the multiselect widget is working
    page.should have_selector(:xpath, "//input[@type='checkbox' and @title='Administrators']")
    member_box = find(:xpath, "//input[@type='checkbox' and @title='Members']")
    
    check 'record_send_email'
    check 'record_send_sms'
    check 'record_news_update'
    find('input.submit').click
    page.should have_content 'You need to write something in your message'
    page.should have_selector(".field_with_errors #record_body")
    # We probably don't need to check all the errors here, rather do it in the model (member_spec)

    # Group selector box should show count of members selected
    2.times {FactoryGirl.create(:member, :groups => [members_group])}
    check 'Members'
    page.should have_content "2 messages"

#binding.pry    
    
  end
  
end
