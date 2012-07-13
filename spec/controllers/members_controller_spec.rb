require 'spec_helper'

describe MembersController do
  
  describe "authentication before controller access" do

    describe "for signed-in admin users" do
 
      before(:each) do
        test_sign_in_fast
      end
      
      it "should allow access to 'new'" do
        Member.should_receive(:new).at_least(1).times # not sure why, but it is receiving msg twice!
        get :new
      end
      
      it "should allow access to 'destroy'" do
        # Member.should_receive(:destroy) # Why can't this work ??
        @member = FactoryGirl.create(:member)
        put :destroy, :id => @member.id
        response.should_not redirect_to(signin_path)
      end
      
      it "should allow access to 'update'" do
        # Member.should_receive(:update)
        @member = FactoryGirl.create(:member)
        put :update, :id => @member.id, :record => @member.attributes, :member => @member.attributes
        response.should_not redirect_to(signin_path)
      end
      
    end # for signed-in users

#    describe "for non-signed-in users" do

#      it "should deny access to 'new'" do
#        get :new
#        response.should redirect_to(signin_path)
#      end

#    end # for non-signed-in users

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
