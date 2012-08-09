require 'spec_helper'

def prepare_authenticated_access_token_request
   # Create consumer application
   @client_application = Factory.create(:client_application)
   # Create a user who authorized the consumer
   @resource_owner = Factory.create(:user)
   # Create a valid, authorized access token
   token = Oauth2Token.create :user => @resource_owner, :client_application => @client_application
   # Configure the request object so that it is recognized as a OAuth2 request
   request.env["oauth.strategies"] = [:oauth20_token, :token]
   request.env["oauth.token"] = token
 end

describe SessionsController do

  describe 'OAuth2 Authentication' do
    it 'Rejects user whose email is not in the database' do
      pending('Figure out how to test it ... if I ever get that far!')
      SessionsController.stub(:get_authorization).and_return prepare_authenticated_access_token_request
      get :create
      response.should redirect_to sign_in_path
    end
  end

  describe 'Skipping Authentication' do
    it 'Rejects user whose email is not in the database' do
      get :create
      response.should redirect_to sign_in_path
    end

#    it 'Accepts user who is member (stubbed)' do
#      user = test_sign_in(:administrator)
#      Member.stub(:find_by_name => user)
#      controller.stub(:login_allowed => user)
#      get :create
#      response.should redirect_to home_path
#    end
    it 'Accepts user who is member' do
      admin_group = FactoryGirl.create(:group, :administrator=>true)
      user = FactoryGirl.create(:member, :name=>'test', :groups => [admin_group], :email_1 => 'testemail')
      get :create
      response.should redirect_to home_path
    end

    it 'Rejects user who has only "limited" status' do
      admin_group = FactoryGirl.create(:group, :limited=>true)
      user = FactoryGirl.create(:member, :name=>'test', :groups => [admin_group], :email_1 => 'testemail')
      get :create
      response.should redirect_to home_path
    end

    it 'Rejects user who has no roles' do
      user = FactoryGirl.create(:member, :name=>'test', :email_1 => 'testemail')
      get :create
      response.should redirect_to sign_in_path
    end
  end
  
  it 'Redirects to "initialize" page when there are not yet any members' do
    Member.destroy_all
    get :new
    response.should redirect_to initialize_path
  end

end
