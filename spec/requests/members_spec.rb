require 'spec_helper'


describe "Members" do
  describe "Signing in:" do
    
    it "Signs in as administrator with admin menu options" do
      # Note that this depends on a specific message being visible on the page ... adjust if needed
      integration_test_sign_in(:administrator)
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
      page.should have_content 'Create new message'
      page.should_not have_content 'Settings'
      page.should_not have_content 'Locations'
      page.should_not have_content 'Log'
      page.should_not have_content 'Message list'
    end

    it "Signs in as limited with limited menu options" do
      # Note that this depends on a specific message being visible on the page ... adjust if needed
# puts "**** before signing in"
      integration_test_sign_in(:limited)
# puts "**** signed in ****"
      page.should have_content 'Signed in as test'
      page.should have_content 'Edit your user info'
      page.should_not have_content 'Create new message'
      page.should_not have_content 'Settings'
      page.should_not have_content 'Locations'
      page.should_not have_content 'Log'
      page.should_not have_content 'Message list'
    end

    it "Cannot sign in without a role" do
      # Note that this depends on a specific message being visible on the page ... adjust if needed
      integration_test_sign_in(:none)
      page.should have_content 'not authorized'
      page.should have_content 'Sign In'
      page.should_not have_content 'Edit your user info'
      page.should_not have_content 'Signed in'
    end

  end
end
