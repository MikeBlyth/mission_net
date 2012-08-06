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
        @user = test_sign_in_fast_with_role(:moderator)
        @user.has_role?(:moderator).should eq true
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
        @user = test_sign_in_fast_with_role(:member)
        @user.has_role?(:member).should eq true
        @user.has_role?(:moderator).should eq false
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
     
end
