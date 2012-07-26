require 'spec_helper'
include SimTestHelper
include SessionsHelper

describe SessionsController do

  describe 'Authentication ' do
    it 'gets user email from Omniauth' do
      pending('Figure out how to test it ... need to set request.env?')
    end
  end
  
  describe 'Login_Allowed checks user for allowed groups' do
    
    it 'accepts user in an allowed group' do
      sec_group = mock_model(Group)
      user = mock_model(Member, :groups => [sec_group])
      Group.stub(:find_by_group_name => sec_group)
      Member.stub(:find_by_email => [user])
      login_allowed('anything').should == user
    end
  end
       

end
