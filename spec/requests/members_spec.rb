require 'spec_helper'


describe "Members" do
  describe "GET /members" do

    it "Signs in as administrator with admin menu options" do
      # Note that this depends on a specific message being visible on the page ... adjust if needed
      integration_test_sign_in
      page.should have_content 'Signed in as test'
      page.should have_content 'Settings'
      page.should have_content 'Locations'
      page.should have_content 'Message list'
      page.should have_content 'Hide menu'
    end

    it "Signs in as moderator with moderator menu options" do
      # Note that this depends on a specific message being visible on the page ... adjust if needed
      integration_test_sign_in(:moderator)
      page.should have_content 'Signed in as test'
      page.should have_content 'Log'
      page.should_not have_content 'Settings'
      page.should_not have_content 'Locations'
      page.should have_content 'Message list'
    end

    it "Signs in as member with member menu options" do
      # Note that this depends on a specific message being visible on the page ... adjust if needed
      integration_test_sign_in(:member)
      page.should have_content 'Signed in as test'
      page.should_not have_content 'Settings'
      page.should_not have_content 'Locations'
      page.should_not have_content 'Log'
      page.should_not have_content 'Message list'
    end

  end
end
