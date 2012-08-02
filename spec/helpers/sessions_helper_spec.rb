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
      current_user_admin?.should be true
      current_user_moderator?.should be true
      current_user_member?.should be true
      current_user_limited?.should be true
    end

    it 'moderator' do
      @user.stub(:groups => [@mod_group])
      current_user_admin?.should be false
      current_user_moderator?.should be true
      current_user_member?.should be true
      current_user_limited?.should be true
    end

    it 'member' do
      @user.stub(:groups => [@member_group])
      current_user_admin?.should be false
      current_user_moderator?.should be false
      current_user_member?.should be true
      current_user_limited?.should be true
    end

    it 'limited' do
      @user.stub(:groups => [@limited_group])
      current_user_admin?.should be false
      current_user_moderator?.should be false
      current_user_member?.should be false
      current_user_limited?.should be true
    end

    it 'nothing' do
      @user.stub(:groups => [@nothing_group])
      current_user_admin?.should be false
      current_user_moderator?.should be false
      current_user_member?.should be false
      current_user_limited?.should be false
    end
  end
end
