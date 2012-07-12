require 'spec_helper'

def seed_statuses
  Status.create(:description => 'On the field', :code => 'on_field', :active => true, :on_field => true,
      :pipeline=>false, :leave=>false, :home_assignment=>false)
  Status.create(:description => 'Pipeline', :code => 'pipeline', :active => false, :on_field => false,
      :pipeline=>true, :leave=>false, :home_assignment=>false)
  Status.create(:description => 'Home_assignment', :code => 'home_assignment', :active => true, :on_field => false,
      :pipeline=>false, :leave=>false, :home_assignment=>true)
  Status.create(:description => 'Leave', :code => 'leave', :active => false, :on_field => false,
      :pipeline=>false, :leave=>true, :home_assignment=>false)
  Status.create(:description => 'Inactive', :code => 'inactive', :active => false, :on_field => false,
      :pipeline=>false, :leave=>false, :home_assignment=>false)
end

describe MembersController do
  
  before(:each) do
  #  @family = Factory(:family)
  #  @member = Factory(:member, :family=>@family)
  #  @family.update_attribute(:head, @member)
  #  Factory(:country_unspecified)
  end

  describe "authentication before controller access" do

    describe "for signed-in admin users" do
 
      before(:each) do
#        @user = Factory(:user, :admin=>true)
#        test_sign_in(@user)
        test_sign_in_fast
      end
      
      it "should allow access to 'new'" do
        Member.should_receive(:new).at_least(1).times # not sure why, but it is receiving msg twice!
        get :new
      end
      
      it "should allow access to 'destroy'" do
        # Member.should_receive(:destroy) # Why can't this work ??
        @member = Factory(:member_without_family)
        put :destroy, :id => @member.id
        response.should_not redirect_to(signin_path)
      end
      
      it "should allow access to 'update'" do
        # Member.should_receive(:update)
        @member = Factory(:member_without_family)
        put :update, :id => @member.id, :record => @member.attributes, :member => @member.attributes
        response.should_not redirect_to(signin_path)
      end
      
    end # for signed-in users

    describe "for non-signed-in users" do

      it "should deny access to 'new'" do
        get :new
        response.should redirect_to(signin_path)
      end

    end # for non-signed-in users

  end # describe "authentication before controller access"

  # These should probably be put into the member MODEL spec
  describe 'filtering by status' do

    before(:each) do
      Member.delete_all  
      seed_statuses
      status_codes = Status.all.map {|status| status.code}
      @status_groups = {:active => ['on_field', 'home_assignment'],
                  :on_field => ['on_field'],
                  :home_assignment => ['home_assignment'],
                  :home_assignment_or_leave => ['home_assignment', 'leave'],
                  :pipeline => ['pipeline'],
                  }
      other = status_codes - @status_groups.values.flatten.uniq
      @status_groups[:other] = other
      # Create a member for each status
      Status.all.each do |status|
        member = Factory(:member_without_family, :status=>status)
      end  
    end
    
    it "should select members with the right status" do
      @status_groups.each do | category, statuses |
        session[:filter] = category.to_s
        selected = Member.where(controller.conditions_for_collection).all
        if selected.count != statuses.count
          puts "Error: looking for category '#{category}' statuses #{statuses}, found"
          selected.each {|m| puts "--#{m.status}"}
        end
        selected.count.should == statuses.count
        selected.each do |m|
          statuses.include?(m.status.code).should be_true
        end
      end
      # An invalid group should return all the members.
      session[:filter] = 'ALL!'
      Member.where(controller.conditions_for_collection).count.should == Member.count
      # A filter=nil should return all the members.
      session[:filter] = nil
      Member.where(controller.conditions_for_collection).count.should == Member.count
      
    end    #  it "should select members with active status"

  end # filtering by status

  describe 'Handling spouses' do
  
    before(:each) do
      @member = Factory(:member_without_family)
      @spouse = Factory.build(:member_without_family, :sex=>@member.other_sex, :spouse=>@member)
#      @user = Factory(:user, :admin=>true)
#      test_sign_in(@user)
      test_sign_in_fast
    end  
  
#    it 'sets previous_spouse in an update' do
#      @spouse.save
#      @member.reload.spouse.should == @spouse
#      @spouse.spouse.should == @member
#      put :update, :id => @member.id, :record => {'short_name' => 'Nicky', 'spouse'=>""}
#      @member.reload.spouse.should == nil
#      @spouse.reload.spouse.should == nil
#    end  

  end
  
  describe 'bug' do
    it 'bugs' do
          session[:filter] = 'active'
          get :index
        end
      end

  describe 'update_statuses method' do
    
    it 'updates the statuses of a group of members' do
      # Using a set of parameters like {... 'member_29'=>{'status_id=>'2'} ...}
#      test_sign_in(Factory.stub(:user, :admin=>true))
      test_sign_in_fast
      id_1 = Factory(:member).id
      id_2 = Factory(:member).id
      params = {:garbage=>'xyz', "member_#{id_1}"=>{'status_id'=>'2'}, "member_#{id_2}"=>{'status_id'=>'5'} }
      put :update_statuses, params
      Member.find(id_1).status_id.should == 2
      Member.find(id_2).status_id.should == 5
    end
  end

  describe 'location status' do
    
    it 'shows on-field member who is out of country' do
      # pending development of this form!
    end
  end # describe 'location status'

  describe 'updating a family from combined form' do
    before (:each) do
#      test_sign_in(Factory.stub(:user, :admin=>true))
      test_sign_in_fast
      @head=Factory(:member)
      @params = {:id=>@head.id, :record=>{}}
    end
      
    it 'updates the member' do
#        lambda {put :update, :id=>@family.id, :record=>{}}.should change(Member, :count).by(0)
      updates = {:head=>{:first_name=>'Gordon'}}
      put :update, @params.merge(updates)
      @head.reload.first_name.should == 'Gordon'
    end  
    
    it 'updates the personnel data' do
#        lambda {put :update, :id=>@family.id, :record=>{}}.should change(Member, :count).by(0)
      updates = {:head_pers=>{:qualifications=>'Wonderful'}}
      put :update, @params.merge(updates)
      @head.reload.personnel_data.qualifications.should == 'Wonderful'
    end  
    
    it 'updates the health data' do
#        lambda {put :update, :id=>@family.id, :record=>{}}.should change(Member, :count).by(0)
      updates = {:health_data=>{:issues=>'sick'}}
      put :update, @params.merge(updates)
      @head.reload.health_data.issues.should == 'sick'
    end  
    
    it 'updates phone numbers and email for head' do
      updates = {:head_contact => {:phone_1 => '+2348088888888', :phone_2 => '0802 222 2222',
                                :email_1 => 'x@y.com', :email_2 => 'cat@dog.com'}}
      post :update, @params.merge(updates)
      @head.reload
      @head.primary_contact.should_not be_nil
      @head.primary_contact.phone_1.should == '+2348088888888'
      @head.primary_contact.phone_2.should == '+2348022222222'
      @head.primary_contact.email_1.should == 'x@y.com'
      @head.primary_contact.email_2.should == 'cat@dog.com'
    end
              
    describe 'updates field term dates' do
      before(:each) do
        @date_1_orig = Date.today+50
        @date_2_orig = Date.today+250
        @date_1 = Date.today+2
        @date_2 = Date.today+100
        @current_term = @head.field_terms.create(:end_date=>@date_1_orig, :end_estimated=>true)
        @next_term = @head.field_terms.create(:start_date=>@date_2_orig)
      end
      
      it 'when new dates are given' do
        updates = {:current_term=>{:end_date=>@date_1.strftime("%F"), :id=>@current_term.id},
                   :next_term=>{:start_date=>@date_2.strftime("%F"), :id=>@next_term.id} }
        put :update, @params.merge(updates)
        @current_term.reload.end_date.should == @date_1           
        @next_term.reload.start_date.should == @date_2
      end

      it 'creates new field_term records if needed' do
        @head.field_terms.destroy_all
        updates = {:current_term=>{:end_date=>@date_1.strftime("%F")},
                   :next_term=>{:start_date=>@date_2.strftime("%F")} }
        put :update, @params.merge(updates)
        @head.reload.most_recent_term.end_date.should == @date_1           
      end
      
      it 'does not update field_term record if new dates are blank' do
        updates = {:current_term=>{:end_date=>"", :id=>@current_term.id},
                   :next_term=>{:start_date=>"", :id=>@next_term.id} }
        put :update, @params.merge(updates)
        @head.reload.most_recent_term.end_date.should == @date_1_orig           
        @head.pending_term.start_date.should == @date_2_orig
      end
        
    end #     'updates field term dates'
           
  end # updating a family

  describe 'Group assignment' do
    it 'assigns groups from multi-select' do
#      test_sign_in(Factory.stub(:user, :admin=>true))
      test_sign_in_fast
      @member = Factory.create(:member)
      @a = Factory.create(:group)
      @b = Factory.create(:group)
      put :update, :id=>@member.id, :head=>{:group_ids=>[@a.id.to_s, @b.id.to_s]}
      @member.reload.group_ids.sort.should == [@a.id, @b.id].sort
    end
  end    

  describe 'Export' do
      before(:each) do
#        @user = Factory(:user, :admin=>true)
#        test_sign_in(@user)
        test_sign_in_fast
      end
    
    it 'CSV sends data file' do
      get :export
      response.headers['Content-Disposition'].should include("filename=\"members.csv\"")
    end
  end # Export
     
end
