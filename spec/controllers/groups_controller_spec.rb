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

end
