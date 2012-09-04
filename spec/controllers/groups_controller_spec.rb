require 'spec_helper'
require 'sim_test_helper'

describe GroupsController do
    before(:each) do
#        @user = Factory(:user, :admin=>true)
#        test_sign_in(@user)
      test_sign_in_fast
    end

  def mock_group(stubs={})
    @mock_group ||= mock_model(Group, stubs).as_null_object
  end

  describe 'create' do

    it 'assigns parameters including parent group' do
      @parent = Group.create(:group_name=>'new parent', :abbrev=>'newparent')
      put :create, :record => {:parent_group_id=>@parent.id, 
        :group_name=>'new_group', :abbrev => 'new'}
      @group = Group.last
      @group.group_name.should eq 'new_group'
      @group.abbrev.should eq 'new'
      @group.parent_group_id.should eq @parent.id
    end
  end

  describe 'update' do
    # I can't figure out how to do this with mocks, given the HABTM relationship
    it 'assigns members from multi-select' do
      @group = Group.create(:group_name=>'new group', :abbrev=>'newgroup')
      @a = FactoryGirl.create(:member)
      @b = FactoryGirl.create(:member)
      put :update, :id=>@group.id, :record => {:member_ids=>[@a.id.to_s, @b.id.to_s]}
      @group.member_ids.sort.should == [@a.id, @b.id].sort
    end

    it 'assigns parent group' do
      @parent = Group.create(:group_name=>'new parent', :abbrev=>'newparent')
      @group = Group.create(:group_name=>'new group', :abbrev=>'newgroup')
      @group.parent_group_id = @parent.id
      @group.should be_valid
      put :update, :id=>@group.id, :record => {:parent_group_id=>@parent.id, :group_name=>'changed'}
      @group.reload.group_name.should == 'changed'
      @group.parent_group_id.should == @parent.id
    end
  end

  describe 'member count' do
  
    it 'returns count of members returned by "members_in_multiple_groups"' do
      Group.stub(:members_in_multiple_groups => [mock_model(Member), mock_model(Member)])
      get :member_count, :to_groups => ['98', '99'], :format => 'js'  # arbitrary numbers not used
      response.body.should eq "2"
    end

    it 'returns count of members when it is zero' do
      Group.stub(:members_in_multiple_groups => [])
      get :member_count, :to_groups => ['98', '99'], :format => 'js'  # arbitrary numbers not used
      response.body.should eq "0"
    end
    
    it 'returns zero when no groups specified' do
      get :member_count, :to_groups => [], :format => 'js'  # arbitrary numbers not used
      response.body.should eq "0"
    end
    
    it 'returns zero when groups parameter absent' do
      get :member_count, :format => 'js'  # arbitrary numbers not used
      response.body.should eq "0"
    end
    
  end # member count
end
