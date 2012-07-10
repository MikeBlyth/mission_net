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
      @family.errors[:last_name].should_not be_nil
    end


#    it "makes a 'name' (full name) by default" do
#      @member.name = ''
#      @member.should be_valid   # because set_indexed_name_if_empty is called before validation
#    end

  end # basic validation

  describe "names: " do
    before(:each) do
      @member = Member.new
      @member.first_name = 'Katarina'
      @member.middle_name = 'Saunders'
      @member.last_name = 'Patterson'
      @member.short_name = 'Kate'
 #     @family.update_attribute(:last_name,'Patterson')
    end  
    
    it "handles various name forms when middle and short names present" do
      @member.short.should == 'Kate'
      @member.middle_initial.should == 'S.'
      @member.to_label.should == 'Patterson, Katarina'
      @member.full_name.should == 'Katarina Saunders Patterson'
      @member.full_name_short.should == 'Kate Patterson'
      @member.full_name_with_short_name.should == 'Katarina Saunders Patterson (Kate)'
      @member.last_name_first.should == 'Patterson, Katarina Saunders'
      @member.last_name_first(:initial=>true).should == 'Patterson, Katarina S.'
      @member.last_name_first(:short=>true).should == 'Patterson, Kate Saunders'
      @member.last_name_first(:paren_short=>true).should == 'Patterson, Katarina (Kate) Saunders'
      @member.last_name_first(:middle=>false).should == 'Patterson, Katarina'
      @member.last_name_first(:short=>true, :initial=>true).should == 'Patterson, Kate S.'
    end

    it "handles various name forms when short but not middle name is present" do
      @member.middle_name = nil
      @member.short.should == 'Kate'
      @member.middle_initial.should == nil
      @member.to_label.should == 'Patterson, Katarina'
      @member.full_name.should == 'Katarina Patterson'
      @member.full_name_short.should == 'Kate Patterson'
      @member.full_name_with_short_name.should == 'Katarina Patterson (Kate)'
      @member.last_name_first.should == 'Patterson, Katarina'
      @member.last_name_first(:initial=>true).should == 'Patterson, Katarina'
      @member.last_name_first(:short=>true).should == 'Patterson, Kate'
      @member.last_name_first(:paren_short=>true).should == 'Patterson, Katarina (Kate)'
      @member.last_name_first(:middle=>false).should == 'Patterson, Katarina'
      @member.last_name_first(:short=>true, :initial=>true).should == 'Patterson, Kate'
    end

    it "handles various name forms when middle but not short name is present" do
      @member.short_name = nil
      @member.indexed_name.should == 'Patterson, Katarina S.'
      @member.short.should == 'Katarina'
      @member.middle_initial.should == 'S.'
      @member.to_label.should == 'Patterson, Katarina'
      @member.full_name.should == 'Katarina Saunders Patterson'
      @member.full_name_short.should == 'Katarina Patterson'
      @member.full_name_with_short_name.should == 'Katarina Saunders Patterson'
      @member.last_name_first.should == 'Patterson, Katarina Saunders'
      @member.last_name_first(:initial=>true).should == 'Patterson, Katarina S.'
      @member.last_name_first(:short=>true).should == 'Patterson, Katarina Saunders'
      @member.last_name_first(:paren_short=>true).should == 'Patterson, Katarina Saunders'
      @member.last_name_first(:middle=>false).should == 'Patterson, Katarina'
      @member.last_name_first(:short=>true, :initial=>true).should == 'Patterson, Katarina S.'
    end

    describe "'short' method (short or first name)" do
      
      it 'returns short_name when it exists' do
        @member.short.should == @member.short_name  # it's Katie by default in this testing
      end
      
      it 'returns first_name when short_name is nil' do
        @member.short_name = nil
        @member.short.should == @member.first_name
      end
      
      it 'returns first_name when short_name is empty string' do
        @member.short_name = ''
        @member.short.should == @member.first_name
      end
      
      it 'returns first_name when short_name is blanks' do
        @member.short_name = '  '
        @member.short.should == @member.first_name
      end
    end # short method (short or first name)
  end

  describe 'finds members by name' do
    before(:each) do
      @member = FactoryGirl.create(:member)
      @member.update_attribute(:short_name, "Shorty")
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

    it 'finds simple name' do  # searching for ONE of last name, first name, short name, full name
      Member.find_with_name(@member.first_name).should == [@member]
      Member.find_with_name(@member.last_name).should == [@member]
      Member.find_with_name(@member.name).should == [@member]
      Member.find_with_name(@member.short_name).should == [@member]
    end

    it 'finds "last_name, first_name"' do  # when this is different from stored full name (#name)
      @member.update_attribute(:name,"xxxx")  # since we're not relying on this
      Member.find_with_name("#{@member.last_name}, #{@member.first_name}").should == [@member]
    end
      
    it 'finds "last_name, short_name"' do  
      Member.find_with_name("#{@member.last_name}, #{@member.short_name}").should == [@member]
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
      
    it 'finds "beginning_of_short_name"' do  
      Member.find_with_name("#{@member.short_name[0..2]}").should == [@member]
    end
      
    it 'finds "beginning_of_last_name"' do  
      Member.find_with_name("#{@member.last_name[0..2]}").should == [@member]
    end

    it 'finds both members with last name' do
      spouse = create_spouse(@member)
      Member.find_with_name("#{@member.last_name}").include?(@member).should be_true
      Member.find_with_name("#{@member.last_name}").should include(spouse)
    end

    it 'finds both members with first name' do
      same_first = FactoryGirl.create(:member, :last_name=>'different', :first_name=>@member.first_name)
      Member.find_with_name("#{@member.first_name}").should include(@member)
      Member.find_with_name("#{@member.first_name}").should include(same_first)
    end

     
  end # finds members by name

  describe 'export' do
    before(:each) do
      @member = Factory.build(:member)
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

