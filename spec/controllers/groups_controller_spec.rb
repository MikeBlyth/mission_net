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

#  describe "GET index" do
#    it "assigns all groups as @groups" do
#      Group.create(:group_name=>'New Group')
##      Group.stub(:all) { [mock_group] }
#      get :index
# puts assigns(:records)
#      assigns(:records).should eq([mock_group])
#    end
#  end

#  describe "GET show" do
#    it "assigns the requested group as @group" do
#      Group.stub(:find).with("37") { mock_group }
#      get :show, :id => "37"
#      assigns(:group).should be(mock_group)
#    end
#  end

#  describe "GET new" do
#    it "assigns a new group as @group" do
#      Group.stub(:new) { mock_group }
#      get :new
#      assigns(:group).should be(mock_group)
#    end
#  end

#  describe "GET edit" do
#    it "assigns the requested group as @group" do
#      Group.stub(:find).with("37") { mock_group }
#      get :edit, :id => "37"
#      assigns(:group).should be(mock_group)
#    end
#  end

#  describe "POST create" do
#    describe "with valid params" do
#      it "assigns a newly created group as @group" do
#        Group.stub(:new).with({'these' => 'params'}) { mock_group(:save => true) }
#        post :create, :group => {'these' => 'params'}
#        assigns(:group).should be(mock_group)
#      end

#      it "redirects to the created group" do
#        Group.stub(:new) { mock_group(:save => true) }
#        post :create, :group => {}
#        response.should redirect_to(group_url(mock_group))
#      end
#    end

#    describe "with invalid params" do
#      it "assigns a newly created but unsaved group as @group" do
#        Group.stub(:new).with({'these' => 'params'}) { mock_group(:save => false) }
#        post :create, :group => {'these' => 'params'}
#        assigns(:group).should be(mock_group)
#      end

#      it "re-renders the 'new' template" do
#        Group.stub(:new) { mock_group(:save => false) }
#        post :create, :group => {}
#        response.should render_template("new")
#      end
#    end
#  end

#  describe "PUT update" do
#    describe "with valid params" do
#      it "updates the requested group" do
#        Group.stub(:find).with("37") { mock_group }
#        mock_group.should_receive(:update_attributes).with({'these' => 'params'})
#        put :update, :id => "37", :group => {'these' => 'params'}
#      end

#      it "assigns the requested group as @group" do
#        Group.stub(:find) { mock_group(:update_attributes => true) }
#        put :update, :id => "1"
#        assigns(:group).should be(mock_group)
#      end

#      it "redirects to the group" do
#        Group.stub(:find) { mock_group(:update_attributes => true) }
#        put :update, :id => "1"
#        response.should redirect_to(group_url(mock_group))
#      end
#    end

#    describe "with invalid params" do
#      it "assigns the group as @group" do
#        Group.stub(:find) { mock_group(:update_attributes => false) }
#        put :update, :id => "1"
#        assigns(:group).should be(mock_group)
#      end

#      it "re-renders the 'edit' template" do
#        Group.stub(:find) { mock_group(:update_attributes => false) }
#        put :update, :id => "1"
#        response.should render_template("edit")
#      end
#    end
#  end

#  describe "DELETE destroy" do
#    it "destroys the requested group" do
#      Group.stub(:find).with("37") { mock_group }
#      mock_group.should_receive(:destroy)
#      delete :destroy, :id => "37"
#    end

#    it "redirects to the groups list" do
#      Group.stub(:find) { mock_group }
#      delete :destroy, :id => "1"
#      response.should redirect_to(groups_url)
#    end
#  end

end
