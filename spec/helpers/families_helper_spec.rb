include FamiliesHelper
include ApplicationHelper
describe FamiliesHelper do

  describe 'formatted data' do

    before(:each) do
      @head = Factory.build(:member, :last_name=>'Frazee', :first_name=>'Darius')
      @wife = Factory.build(:member, :sex=>'F', :first_name=>'Mary', :last_name=>@head.last_name)
      @family = Factory.build(:family, :head=>@head, :last_name=>@head.last_name)
      @contact = Factory.build(:contact)
      @contact_wife = Factory.build(:contact, :phone_1=>'+2348165555555', :email_1=>'mary@frazee.com')
      @head.stub(:primary_contact).and_return(@contact)
      @wife.stub(:primary_contact).and_return(@contact_wife)
      @family.stub(:wife).and_return(@wife)
      @family.stub(:children_names).and_return(['Erin', 'Callen'])
    end
  
    it 'gives formatted hash' do
      puts "family_data_formatted = #{family_data_formatted(@family)}"
    end  

    it 'shows non-private phone number' do
      @contact.phone_private = false
      family_data_formatted(@family)[:phones].include?(format_phone(@contact.phone_1)).should == true
      family_data_formatted(@family)[:phones].include?(format_phone(@contact_wife.phone_1)).should == true
    end  
      
    it 'hides husband''s private phone number' do
      @contact.phone_private = true
      puts "Private phone for husband => #{family_data_formatted(@family)}"
      family_data_formatted(@family)[:phones].include?(format_phone(@contact.phone_1)).should == false
      family_data_formatted(@family)[:phones].include?(format_phone(@contact_wife.phone_1)).should == true
    end  
      
    it 'hides wife''s private phone number' do
      @contact_wife.phone_private = true
      puts "Private phone for wife => #{family_data_formatted(@family)}"
      family_data_formatted(@family)[:phones].include?(format_phone(@contact.phone_1)).should == true
      family_data_formatted(@family)[:phones].include?(format_phone(@contact_wife.phone_1)).should == false
    end  
      
    it 'hides both private phone numbers' do
      @contact_wife.phone_private = true
      @contact.phone_private = true
      puts "Private phone for both => #{family_data_formatted(@family)}"
      family_data_formatted(@family)[:phones].include?(format_phone(@contact.phone_1)).should == false
      family_data_formatted(@family)[:phones].include?(format_phone(@contact_wife.phone_1)).should == false
    end  
      
  end # formatted data  

end

