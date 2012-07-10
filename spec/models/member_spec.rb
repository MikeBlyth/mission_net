require 'spec_helper'
require 'sim_test_helper'
include SimTestHelper

describe Member do

  describe 'does basic validation' do
    before(:each) do
      @member = FactoryGirl.create(:member)
    end    
    
    it "can make a factory member" do
    end

    it "is valid with valid attributes" do
      @member.should be_valid
    end

    it "is not valid without a first name" do
      @member.first_name = ''
      @member.should_not be_valid
      @member.errors[:first_name].should_not be_nil
    end

    it "is not valid without a last name" do
      @member.last_name = ''
      @member.should_not be_valid
    end

  end # basic validation

  describe "names: " do
    before(:each) do
      @member = Member.new
      @member.first_name = 'Katarina'
      @member.middle_name = 'Saunders'
      @member.last_name = 'Patterson'
     end  
    
  end # names

  describe 'finds members by name' do
    before(:each) do
      @member = FactoryGirl.create(:member)
    end

    it 'return empty array if name not found' do
      Member.find_with_name('stranger').should == []
    end

    it 'returns empty array if name blank' do
      Member.find_with_name('').should == []
    end

    it 'returns empty array if name nil' do
      Member.find_with_name(nil).should == []
    end

    it 'finds simple name' do  # searching for ONE of last name, first name, full name
      Member.find_with_name(@member.first_name).should == [@member]
      Member.find_with_name(@member.last_name).should == [@member]
      Member.find_with_name(@member.name).should == [@member]
    end

    it 'finds "last_name, first_name"' do  # when this is different from stored full name (#name)
      @member.update_attribute(:name,"xxxx")  # since we're not relying on this
      Member.find_with_name("#{@member.last_name}, #{@member.first_name}").should == [@member]
    end
      
    it 'finds "last_name, initial"' do  
      Member.find_with_name("#{@member.last_name}, #{@member.first_name[0]}").should == [@member]
    end
      
    it 'finds "first_name last_name"' do  
      Member.find_with_name("#{@member.first_name} #{@member.last_name}").should == [@member]
    end
      
    it 'finds "beginning_of_first_name beginning_of_last_name"' do  
      Member.find_with_name("#{@member.first_name[0..2]} #{@member.last_name[0..1]}").should == [@member]
    end
      
    it 'finds "beginning_of_first_name"' do  
      Member.find_with_name("#{@member.first_name[0..2]}").should == [@member]
    end
      
    it 'finds "beginning_of_last_name"' do  
      Member.find_with_name("#{@member.last_name[0..2]}").should == [@member]
    end

    it 'finds both members with first name' do
      same_first = FactoryGirl.create(:member, :last_name=>'different', :first_name=>@member.first_name)
      Member.find_with_name("#{@member.first_name}").should include(@member)
      Member.find_with_name("#{@member.first_name}").should include(same_first)
    end
     
  end # finds members by name

  describe 'export' do
    before(:each) do
      @member = FactoryGirl.build(:member)
      Member.stub(:all).and_return([@member])
    end      

    it 'makes csv object' do
#      @on_field = Factory.build(:status) # "field" is true by default
      csv = Member.export ['last_name',]
      csv.should match(@member.last_name)
    end

    # Todo: Refactor next two into tests just for csv_helper or export
    it 'gracefully ignores unknown column names' do
      csv = Member.export ['last_name', 'xxxxxzzzz']
      csv.should match(@member.last_name)
    end

    it 'handles case with no column names' do
      # This test will pass regardless of what export returns; we just want to know that it doesn't crash
      csv = Member.export [] 
    end
      
  end # Export

end

