require 'spec_helper'

describe "Members" do
  describe "Signing in:" do
    
ActiveSupport::Deprecation.silence do
    it "Signs in as administrator with admin menu options" do
      # Note that this depends on a specific message being visible on the page ... adjust if needed
      integration_test_sign_in(:administrator)
      page.should have_content 'Signed in as test'
      page.should have_content 'Settings'
      page.should have_content 'Locations'
      page.should have_content 'Message list'
      page.should have_content 'Hide menu'
#save_and_open_page
      page.should have_content "Click to show more columns"
    end
end
    it "Signs in as moderator with moderator menu options" do
      # Note that this depends on a specific message being visible on the page ... adjust if needed
      integration_test_sign_in(:moderator)
      page.should have_content 'Signed in as test'
      page.should have_content 'Log'
      page.should_not have_content 'Settings'
      page.should_not have_content 'Locations'
      page.should have_content 'Message list'
    end

    it "Signs in as member with member menu options" do
      # Note that this depends on a specific message being visible on the page ... adjust if needed
      integration_test_sign_in(:member)
      page.should have_content 'Signed in as test'
      page.should have_content 'Create new message'
      page.should_not have_content 'Settings'
      page.should_not have_content 'Locations'
      page.should_not have_content 'Log'
      page.should_not have_content 'Message list'
    end

    it "Signs in as limited with limited menu options" do
      # Note that this depends on a specific message being visible on the page ... adjust if needed
# puts "**** before signing in"
      integration_test_sign_in(:limited)
# puts "**** signed in ****"
      page.should have_content 'Signed in as test'
      page.should have_content 'Edit your user info'
      page.should_not have_content 'Create new message'
      page.should_not have_content 'Settings'
      page.should_not have_content 'Locations'
      page.should_not have_content 'Log'
      page.should_not have_content 'Message list'
    end

    it "Cannot sign in without a role" do
      # Note that this depends on a specific message being visible on the page ... adjust if needed
      integration_test_sign_in(:none)
      page.should have_content 'not authorized'
      page.should have_content 'Sign In'
      page.should_not have_content 'Edit your user info'
      page.should_not have_content 'Signed in'
    end

  end

  describe 'Show a member' do
    before(:each) do
      @member = FactoryGirl.create(:member)
    end
    
    it 'shows all fields to admin user', :js => true do
      integration_test_sign_in(:administrator)
#      visit member_path(@member)
      click_link "Show"
      save_and_open_page
      page.should have_content @member.name
      page.should have_content @member.first_name
      page.should have_content @member.email_1
      page.should have_content @member.email_2
      page.should have_content format_phone(@member.phone_1, :unbreakable => true)
      page.should have_content format_phone(@member.phone_2, :unbreakable => true)
      page.should have_content @member.emergency_contact_email
      page.should have_content @member.emergency_contact_phone
      page.should have_content @member.bloodtype
      
    end
     
  end # Show a member

  describe 'Editing a member' do
    
    it 'successfully updates all fields' do
      member = integration_test_sign_in(:moderator) # This also puts member into "Group 1"
      FactoryGirl.create(:country, :name => 'Kenya')
      FactoryGirl.create(:country, :name => 'Narnia')
      admin_group = FactoryGirl.create(:group, :group_name => 'Administrators', :administrator => true)
      members_group = FactoryGirl.create(:group, :group_name => 'Members', :member => true)
      FactoryGirl.create(:group, :group_name => 'Limited', :limited => true)
      FactoryGirl.create(:bloodtype, :full => 'A pos')
      FactoryGirl.create(:bloodtype, :full => 'B neg')
      city = FactoryGirl.create(:city)
      FactoryGirl.create(:location, :description => 'Cair Paravel', :city => city)
      click_link "Edit your user info"
      fill_in "First name", :with => "Samuel"
      fill_in "Last name", :with => "Berkhold"
      fill_in "Middle name", :with => "Jonah"
      fill_in "Short name", :with => "Sam"
      fill_in "record_name", :with => "Berkhold, Sam"
      select "Nar", :from=>'record_country' 
      select "Mem", :from=>'record_groups' 
      unselect "Group", :from=>'record_groups'
      fill_in "record_phone_1", :with => '12345678'
      fill_in "record_phone_2", :with => '88888888'
      fill_in "record_email_1", :with => 'tom@test.com'
      fill_in "record_email_2", :with => 'jane@test.com'
      fill_in "record_emergency_contact_name", :with => 'Robin Hood'
      fill_in "record_emergency_contact_phone", :with => '7094444444'
      fill_in "record_emergency_contact_email", :with => 'griffin@zoo.com'
      check "record_phone_private"
      check "record_email_private"
      select "Cair", :from => 'record_location'
      fill_in "record_location_detail", :with => 'dungeon'
      uncheck "record_in_country"
      check "record_blood_donor"
      select "A pos", :from => 'record_bloodtype'
      select "2013", :from => 'record_arrival_date_1i'
      select "Dec", :from => 'record_arrival_date_2i'
      select "24", :from => 'record_arrival_date_3i'
      select "2014", :from => 'record_departure_date_1i'
      select "Nov", :from => 'record_departure_date_2i'
      select "23", :from => 'record_departure_date_3i'
      fill_in 'record_comments', :with => 'Comments please'
      click_button 'Update'
      #***************** NOW WE HAVE THE MEMBER LISTING WITH THE FLASH NOTICE THAT MEMBER HAS BEEN UPDATED
      page.should have_content 'Updated Berkhold, Samuel'
      values = member.reload.attributes
      begin
          {'first_name' => "Samuel", 'last_name'=> 'Berkhold', 'name'=> 'Berkhold, Sam', 'short_name' => 'Sam',
             'country'=> 'Narnia', 'groups'=> [members_group].to_s, 'phone_1'=> '12345678', 'phone_2'=> '88888888',
             'email_1'=> 'tom@test.com', 'email_2'=> 'jane@test.com', 'emergency_contact_name'=> 'Robin Hood',
             'emergency_contact_phone' => '7094444444', "emergency_contact_email" => 'griffin@zoo.com',
             'phone_private' =>'true', 'email_private' => 'true',
             'location' => 'Cair Paravel', 'location_detail' => 'dungeon', 'in_country' => 'false',
             'blood_donor' => 'true', 'departure_date' => Date.new(2014, 11, 23).to_s(:default), 
             'arrival_date' => Date.new(2013, 12, 24).to_s(:default), 'comments' => 'Comments please'
            }.each do |key, value| 
              # Debugging line below
              # puts "**** Entered field #{key} should=#{value}; record has #{member.send(key)}" 
              member.send(key).to_s.should == value
            end
      rescue
       puts "\n**************** TEST FAILED ... SEE THIS NOTE: ************************"  
       puts     'Note: ActiveScaffold may not be updating some fields. See Member.update where some manual'
       puts     'updates are made after call to "super". Failures may be a result of this. Also, this test '
       puts     'uses string representations for comparison, which might change if formatting etc. is changed.'
       raise
      end                
    end # it successfully updates all fields
  end # Editing a member
end  
