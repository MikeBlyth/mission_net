require 'spec_helper'
require 'sessions_helper'

# Specs in this file have access to a helper object that includes
# the SessionsHelper. For example:
#
# describe SessionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe SessionsHelper do
  before(:each) do
    @admin_group = FactoryGirl.build_stubbed(:group, :administrator => true)
    @mod_group = FactoryGirl.build_stubbed(:group, :moderator => true)
    @member_group = FactoryGirl.build_stubbed(:group, :member => true)
    @limited_group = FactoryGirl.build_stubbed(:group, :limited => true)
    @nothing_group = FactoryGirl.build_stubbed(:group)
  end
    
  describe 'Login_Allowed:' do
    
    it 'finds member with highest privileges when members share email address' do
      email = 'ok@test.com'
      sec_group = FactoryGirl.create(:group, :group_name => 'Security leaders', :moderator => true)
      admin_group = FactoryGirl.create(:group, :group_name => 'Administrators', :administrator => true)
      non_member = FactoryGirl.create(:member, :email_1 => email) 
      member = FactoryGirl.create(:member, :groups => [sec_group], :email_1 => email)     
      administrator = FactoryGirl.create(:member, :groups => [sec_group, admin_group], :email_1 => email) 
      Member.stub(:find_by_email => [non_member, member, administrator])
      administrator.reload.groups.should include admin_group
      user = login_allowed(email)
      user.should == administrator
    end
      
    it 'accepts login by administrator' do
      user = mock_model(Member, :role => :administrator)
      Member.stub(:find_by_email => [user])
      login_allowed('anything').should == user
    end

    it 'accepts login by moderator' do
      user = mock_model(Member, :role => :moderator)
      Member.stub(:find_by_email => [user])
      login_allowed('anything').should == user
    end

    it 'accepts login by member' do
      user = mock_model(Member, :role => :member)
      Member.stub(:find_by_email => [user])
      login_allowed('anything').should == user
    end

    it 'accepts login by limited member' do
      user = mock_model(Member, :role => :limited)
      Member.stub(:find_by_email => [user])
      login_allowed('anything').should == user
    end

    it 'rejects login by user with no role' do
      user = mock_model(Member, :role => nil)
      Member.stub(:find_by_email => [user])
      login_allowed('anything').should == false
    end

  end
       
end
