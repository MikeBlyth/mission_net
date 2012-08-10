require 'spec_helper'

describe MembersController do
  
  describe "authentication before controller access" do
    before(:each) do
    end
    
    describe "for signed-in admin users" do
      before(:each) do
        test_sign_in_fast
      end
 
      it "should allow access to 'new'" do
        Member.should_receive(:new).at_least(1).times # not sure why, but it is receiving msg twice!
        get :new
      end
      
      it "should allow access to 'destroy'" do
        # Member.should_receive(:destroy) # Why can't this work ?? (Probably because it should be member instance and not Member class?
        @member = FactoryGirl.create(:member)
        put :destroy, :id => @member.id
        response.should_not redirect_to(sign_in_path)
      end
      
      it "should allow access to 'update'" do
        # Member.should_receive(:update)
        @member = FactoryGirl.create(:member)
        put :update, :id => @member.id, :record => @member.attributes
        response.should_not redirect_to(sign_in_path)
      end
      
    end # for signed-in users

    describe "for moderators" do
      before(:each) do
        @user = test_sign_in(:moderator)
        @user.role.should eq :moderator
      end

      it 'allows moderators to create' do
        member = FactoryGirl.build_stubbed(:member)
        lambda{post :create, 'record' => member.attributes}.should change{Member.count}.by(1)
        response.should_not redirect_to(sign_in_path)
      end

      it 'allows moderators to update' do
        @member = FactoryGirl.create(:member)
        put :update, :id => @member.id, :record => @member.attributes
        response.should_not redirect_to(sign_in_path)
      end

    end

    describe "for members" do
      before(:each) do
        @user = test_sign_in_fast(:member)
        @user.role.should eq :member
      end

      it 'does not allow _members_ to update' do
        @member = FactoryGirl.create(:member)
        put :update, :id => @member.id, :record => @member.attributes
        response.should redirect_to(safe_page_path)
      end

      it 'does members to update their own record' do
        @member = FactoryGirl.build(:member)
        @member.id = @user.id
        @member.save
        put :update, :id => @member.id, :record => @member.attributes
        response.should_not redirect_to(safe_page_path)
      end

    end # for members

    describe "for non-signed-in users" do

      it "should deny access to 'new'" do
        get :new
        response.should redirect_to(sign_in_path)
      end

    end # for non-signed-in users
    
  end # describe "authentication before controller access"

  describe 'Export' do
      before(:each) do
#        @user = FactoryGirl.create(:user, :admin=>true)
#        test_sign_in(@user)
        test_sign_in_fast
      end
    
    it 'CSV sends data file' do
      get :export
      response.headers['Content-Disposition'].should include("filename=\"members.csv\"")
    end
  end # Export

  describe 'Updating groups:' do
    
    def create_test_groups_for_selectability
      # Create 2 groups that are user selectable, 2 that are not, and 1 administrator group
      @selectable_1 = FactoryGirl.create(:group, :id => 1, :user_selectable => true)
      @selectable_2 = FactoryGirl.create(:group, :id => 2, :user_selectable => true)
      @un_selectable_3 = FactoryGirl.create(:group, :id => 3, :user_selectable => false)
      @un_selectable_4 = FactoryGirl.create(:group, :id => 4, :user_selectable => false)
      @admin_group_5 = FactoryGirl.create(:group, :id => 5, :administrator => true)
      @original_groups = [@selectable_1, @un_selectable_3] # One selectable and one un-selectable group are originally in record
    end

    describe 'filter for group selection:' do

      it 'administrator gets unfiltered group list' do
        test_sign_in(:administrator)
        2.times {FactoryGirl.create(:group)}
        member = FactoryGirl.create(:member)
        get :edit, :id => member.id, :record => member.attributes
        assigns(:selectable).should eq 'true'  # Group.where('true') will find all groups
      end

      it 'moderator gets an "anyone-but-administrator"' do
        test_sign_in(:moderator)
        2.times {FactoryGirl.create(:group)}
        member = FactoryGirl.create(:member)
        get :edit, :id => member.id, :record => member.attributes
        assigns(:selectable).should eq "administrator = 'f' OR administrator IS NULL"  # Group.where('true') will find all groups
      end

      it 'member gets only "user_selectable" filter string' do
        member = create_signed_in_member(:member)
        selectable = FactoryGirl.create(:group, :user_selectable => true)
        not_selectable = FactoryGirl.create(:group, :user_selectable => false)
        get :edit, {:id => member.id, :record => member.attributes}
        assigns(:selectable).should eq 'user_selectable'  # will find only groups with that attribute  
      end
    end # filter for group selection:
    
    describe 'merge_group_ids method yields valid new group_ids' do
      # This method handles the incoming (from form) group ids and only allows changes to
      # the groups allowed for the given user role (privilege).
      before(:each) do  
        create_test_groups_for_selectability
      end             

      it 'handles empty update list' do
        test_sign_in(:moderator)  # Not administrator, since admin doesn't use merge_group_ids anyway
        Member.stub_chain(:find, :groups).and_return(@original_groups)
        controller.merge_group_ids({:record=>{:groups => []}, :id => 1}).sort.should == []
        controller.merge_group_ids({:record=>{:groups => ['']}, :id => 1}).sort.should == []
        controller.merge_group_ids({:record=>{:id => 1}}).sort.should == []
      end

      it 'does not drop an assigned, unselectable group' do
        # This just tests the merge_group_ids method directly without going through Member.update
        test_sign_in(:member)
        Member.stub_chain(:find, :groups).and_return(@original_groups)
        Member.find(1).groups.should == @original_groups
        controller.merge_group_ids({:record=>{:groups => ["1", '3']}, :id => 1}).sort.should == ['1', '3']
        #          method          {incoming parameters from form},   record being edited})
        controller.merge_group_ids({:record=>{:groups => ["2", '4']}, :id => 1}).sort.should == ['2', '3']
        # i.e., (1 and 2) can be updated (from '1' to '2') but (3 and 4) are not (so 3 remains as 3)
      end
    end # merge_group_ids method yields valid new group_ids

    describe 'only changeable groups are changed on update' do

      before(:each) do  
        create_test_groups_for_selectability
      end             
              
      it 'member can change only the selectable groups in the database record' do
        member = create_signed_in_member(:member)
        role_group = member.groups[0]  # This is one we had to create to give the member privilege
        member.groups << [@selectable_1, @un_selectable_3]
        member.role.should eq :member
        params = member.attributes.merge({:groups => ['2', '4', '5']})
        put :update, :id => member.id, :record => params
        member.reload.group_ids.sort.should eq [2, 3, role_group.id].sort  # 4 doesn't appear, 3 doesn't disappear; role_group is left over from first line
      end

      it 'moderator can change selectable and un-selectable groups in the database record' do
        test_sign_in(:moderator)
        member = FactoryGirl.create(:member, :groups => [@selectable_1, @un_selectable_3])
        params = member.attributes.merge({:groups => ['2', '4']})
        put :update, :id => member.id, :record => params
        member.reload.group_ids.sort.should eq [2, 4]  # 4 does appear and 3 is dropped, even though un-selectable
      end

      it 'moderator cannot add or remove member from administrator group' do
        test_sign_in(:moderator)
        member = FactoryGirl.create(:member, :groups => [@selectable_1, @un_selectable_3])
        params = member.attributes.merge({:groups => ['2', '4', '5']})
        put :update, :id => member.id, :record => params
        member.reload.group_ids.sort.should eq [2, 4]  # 5 (admin) does not appear
      end

      it 'administrator can change all groups including administrator groups' do
        test_sign_in(:administrator)
        member = FactoryGirl.create(:member, :groups => [@selectable_1, @un_selectable_3])
        params = member.attributes.merge({:groups => ['2', '4', '5']})  # where '5' is administrator group
        put :update, :id => member.id, :record => params
        member.reload.group_ids.sort.should eq [2, 4, 5]  # '5' means admin group has been added
      end

    end # only changeable groups are changed on update

  end # updating groups
end
