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
    

  describe 'finds highest privilege level in an array of groups' do
    it 'finds administrator' do
      highest_privilege([@admin_group, @nothing_group, @member_group, @mod_group, @limited_group]).should == :administrator
    end
    
    it 'finds moderator' do
      highest_privilege( [@nothing_group, @member_group, @mod_group, @limited_group]).should == :moderator
    end
    
    it 'finds member' do
      highest_privilege([ @member_group,  @nothing_group, @limited_group]).should == :member
    end
    
    it 'finds limited user' do
      highest_privilege([@nothing_group, @limited_group]).should == :limited
    end
    
    it 'finds "member" (person) with no privileges' do
      highest_privilege([@nothing_group]).should be nil
    end
  end      

  describe 'it determines whether user has privileges:' do
    before(:each) do
      @user = FactoryGirl.build_stubbed(:member)
      Member.stub(:find => @user)  # so that current_user will return @user
      @current_user = @user
    end
    
    it 'administrator' do
      @user.stub(:groups => [@admin_group, @mod_group])
      administrator?(@user).should be true
      moderator?(@user).should be true
      member?(@user).should be true
      limited?(@user).should be true
    end

    it 'moderator' do
      @user.stub(:groups => [@mod_group])
      administrator?(@user).should be false
      moderator?(@user).should be true
      member?(@user).should be true
      limited?(@user).should be true
    end

    it 'member' do
      @user.stub(:groups => [@member_group])
      administrator?(@user).should be false
      moderator?(@user).should be false
      member?(@user).should be true
      limited?(@user).should be true
    end

    it 'limited' do
      @user.stub(:groups => [@limited_group])
      administrator?(@user).should be false
      moderator?(@user).should be false
      member?(@user).should be false
      limited?(@user).should be true
    end

    it 'nothing' do
      @user.stub(:groups => [@nothing_group])
      administrator?(@user).should be false
      moderator?(@user).should be false
      member?(@user).should be false
      limited?(@user).should be false
    end
  end

  describe 'Login_Allowed checks user for allowed groups' do
    
    it 'accepts user in an allowed group' do
      sec_group = mock_model(Group, :member => true)
      user = mock_model(Member, :groups => [sec_group])
      Group.stub(:find_by_group_name => sec_group)
      Member.stub(:find_by_email => [user])
      login_allowed('anything').should == user
    end

    it 'rejects user with no privileges' do
      unprivileged_group = mock_model(Group)
      user = mock_model(Member, :groups => [unprivileged_group])
      Group.stub(:find_by_group_name => unprivileged_group)
      Member.stub(:find_by_email => [user])
      login_allowed('anything').should be false
    end

    it 'rejects user with limited privileges' do
      limited_group = mock_model(Group, :limited => true)
      user = mock_model(Member, :groups => [limited_group])
      Group.stub(:find_by_group_name => limited_group)
      Member.stub(:find_by_email => [user])
      login_allowed('anything').should be false
    end

    it 'rejects user with no groups' do
      user = mock_model(Member, :groups => [])
      Member.stub(:find_by_email => [user])
      login_allowed('anything').should be false
    end

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
      
  end
       

end
