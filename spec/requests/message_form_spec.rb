# NB This test probably fails when run under Spork. Don't know why.
require 'spec_helper'
require 'fake_web'
include ApplicationHelper
require 'messages_test_helper'
include MessagesTestHelper

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
    check 'record_send_sms'  # Leave unchecked because sending SMS invokes DelayedJob, leading to complications with testing
    check 'record_news_update'
    find('input.submit').click
    page.should have_content 'You need to write something in your message'
    page.should have_selector(".field_with_errors #record_body")
    # We probably don't need to check all the errors here, rather do it in the model (member_spec)

    # Group selector box should show count of members selected
    2.times {FactoryGirl.create(:member, :groups => [members_group])}
    check 'Members'
    page.should have_content "2 messages"
    fill_in "record_subject", :with => "Subject line"
    fill_in "record_body", :with => "Message body"
    find('input.submit').click
    page.should have_content 'Status summary'  # for time out
    page.should have_link 'Follow up'  # for time out
    msg = Message.last
    id = msg.id
    subject = msg.subject
    subject.should eq 'Subject line'
    msg.body.should eq 'Message body'
    click_link 'Follow up'
    # Now we have new page, the one for entering f/u message.
    page.should have_content I18n.t('messages.followup.form_descr_1', :id => id)
    find('#record_sms_only').should have_content I18n.t('messages.followup.sms_line', :id => id, :subject => subject)
    find('#record_subject').value.should eq I18n.t('messages.followup.subject_line', :id => id, :subject => subject)
    find('#record_body').value.should eq I18n.t('messages.followup.body_content', :id => id, :subject => subject)
    page.should have_selector('input#record_send_email')
    page.should have_selector('input#record_send_sms')
    page.should have_selector('input#record_news_update')
    check 'Send email'
    click_button("Send")
    page.should have_content 'Status summary'  # for time out
    
  end
  
end
