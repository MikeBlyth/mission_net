require 'spec_helper'
require 'fakeweb.rb'

describe "Login" do
  before(:each) do
    visit sign_in_path
  end

  it 'accepts valid user via Google OAuth2' do
    FakeWeb.register_uri(:get, %r/google.*oauth2/i, :body => "Hello World!")
    click_link "connect_google"
  end
end

#      it "should not create a new user with missing values" do
#        lambda do
#          visit new_user_path
#          fill_in "Name",         :with => ""
#          fill_in "Email",        :with => ""
#          fill_in "Password",     :with => ""
#          fill_in "Confirmation", :with => ""
#          click_button "user_submit"
##            page.should have_content("Email can't be blank")
#          page.should have_content("Email can't be blank")
#          page.should have_content("Name can't be blank")
#          page.should have_content("Email is invalid")
#          page.should have_content("Password can't be blank")
#          page.should have_content("too short")
#        end.should_not change(User, :count)
#      end # it should

#      it "should create a new user with good values" do
#        lambda do
#          visit new_user_path
#          fill_in "Name",         :with => "Example User"
#          fill_in "Email",        :with => "user@example.com"
#          fill_in "Password",     :with => "foobar"
#          fill_in "Confirmation", :with => "foobar"
#          click_button "Create"
#          page.should have_selector("div.flash.success",
#                                        :content => "Successfully")
#        end.should change(User, :count).by(1)
#      end #it should
#    end # Creating New User

#    it "edit form should not have field for Admin privileges" do
#      visit edit_user_path @user
#      page.should have_content("Edit User")
#      page.should_not have_content("Administrator")
#    end

#  end # by Administrator 

#  describe "by Non-administrator" do
#    before(:each) { integration_test_sign_in(:admin=>false)}

#    it "should not create a new user even with good values" do
#      visit new_user_path @user
#      page.should have_selector("title", :content => "SIM")
#      page.should have_selector("div.flash.alert")
#    end

#    it 'should allow user to edit his own record' do
##puts "Edit own record for user #{@user.id}, path=#{edit_user_path @user}"
#      visit edit_user_path @user
#      page.should have_content("Edit User")
#    end

#    it 'should not allow user to edit other user records' do
#      other_user = Factory(:user)
##puts "#{@user.id} edit record for other user #{other_user.id}, path=#{edit_user_path other_user}"
#      visit edit_user_path other_user
#      page.should_not have_content("Edit User")
#    end

#  end # "by Non-administrator"

#  describe "sign in/out" do

#    describe "failure" do
#      it "should not sign a user in with missing values" do
#        visit signin_path
#        fill_in "Name",    :with => ""
#        fill_in "Password", :with => ""
#        click_button "Sign in"
#        page.should have_selector("div.flash.error", :content => "Invalid")
#      end
#    end #failure

#    describe "success" do
#      it "should sign a user in and out with right values" do
#       user = Factory(:user)
#        visit signin_path
#        fill_in "Name",    :with => user.name
#        fill_in "Password", :with => user.password
#        click_button "Sign in"
#        page.should have_selector("a", :content => "Sign out")
#        click_link "Sign out"
#        page.should have_selector("a", :content => "Sign in")
#      end
#    end #success
#  end # sign in/out

#end
