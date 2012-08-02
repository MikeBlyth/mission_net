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

    it 'finds member with highest privileges when members share email address' do
      email = 'ok@test.com'
      sec_group = FactoryGirl.create(:group, :group_name => 'Security leaders')
      admin_group = FactoryGirl.create(:group, :group_name => 'Administrators')
      non_member = FactoryGirl.create(:member, :email_1 => email) 
      member = FactoryGirl.create(:member, :groups => [sec_group], :email_1 => email)     
      administrator = FactoryGirl.create(:member, :groups => [sec_group, admin_group], :email_1 => email) 
      Member.stub(:find_by_email => [non_member, member, administrator])
      administrator.reload.groups.should include admin_group
      user = login_allowed(email)
      user.should == administrator
    end
      
  end
       

end
