# == Schema Information
#
# Table name: groups
#
#  id              :integer         not null, primary key
#  group_name      :string(255)
#  parent_group_id :integer
#  abbrev          :string(255)
#  primary         :boolean
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

require 'spec_helper'

# == Schema Information
#
# Table name: groups
#
#  id              :integer         not null, primary key
#  group_name      :string(255)
#  parent_group_id :integer
#  abbrev          :string(255)
#  primary         :boolean
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#
describe Group do
  
  it 'returns list of primary groups' do
    group_1 = FactoryGirl.create(:group, :primary => true, :abbrev => '1')
    group_2 = FactoryGirl.create(:group, :primary => false, :abbrev => '2')
    group_3 = FactoryGirl.create(:group, :primary => true, :abbrev => '3')
    list = Group.primary_group_abbrevs
    list.should =~ /1/
    list.should =~ /3/
    list.should_not =~ /2/
  end
    

  describe 'members_with_subgroups  ' do
    before(:each) do
        # Make 3-level group tree from stubs. It ain't pretty but it's pretty fast!
        @top = FactoryGirl.build(:group, :group_name=>'top')
        @mid_1 = FactoryGirl.build(:group, :group_name=>'mid_1', :parent_group => @top)
        @mid_2 = FactoryGirl.build(:group, :group_name=>'mid_2', :parent_group => @top)
        @low_1a = FactoryGirl.build(:group, :group_name=>'low_1a', :parent_group => @mid_1)
        @low_1b = FactoryGirl.build(:group, :group_name=>'low_1b', :parent_group => @mid_1)
        @low_2a = FactoryGirl.build(:group, :group_name=>'low_2a', :parent_group => @mid_2)
        @low_2b = FactoryGirl.build(:group, :group_name=>'low_2b', :parent_group => @mid_2)
        @mid_1.subgroups = [@low_1a, @low_1b]
        @mid_2.subgroups = [@low_2a, @low_2b]
        @top.subgroups = [@mid_1, @mid_2]
        @mid_2.stub(:member_ids).and_return([8])
        @low_2a.stub(:member_ids).and_return([6])
        @low_2b.stub(:member_ids).and_return([2,4])
        @mid_1.stub(:member_ids).and_return([3])
        @low_1a.stub(:member_ids).and_return([5])
        @low_1b.stub(:member_ids).and_return([1,7])
        @top.stub(:member_ids).and_return([])
    end
  
    it 'members_with_subgroups finds members in group and subgroups' do
      @low_1a.members_with_subgroups.should == [5]
      @mid_1.members_with_subgroups.sort.should == [1,3,5,7]
      @mid_2.members_with_subgroups.sort.should == [2,4,6,8]
      @top.members_with_subgroups.sort.should == [1,2,3,4,5,6,7,8]
    end
    
    it 'finds members belonging to one of an array of group ids' do
    # This is a kludgy test. It just checks that 'members_in_multiple_groups' causes
    # Member to select members with the right ids. To avoid using the database, we
    # have multiple levels of mocks. Also, this is quite coupled with the actual method,
    # since it only works with the 'where' method with :id=>[array of members].

      Member.stub(:where => Member)
      Group.stub(:find_by_id) do |id|
        if id == 1           
          @mid_2
        else
          @low_1b
        end
      end
      Member.should_receive(:where).with(:id=>[1,2,4,6,7,8])
      Group.members_in_multiple_groups([1,2]) # all branch 2 plus 1b
    end
  end # members_with_subgroups 
  
  describe 'group_member_names' do
    before(:each) do
      @members = (1..12).map {|i| mock('Member', :full_name_short => "M_#{i}")}
      @group = FactoryGirl.build_stubbed(:group)
    end
  
    it 'returns string of short names of members' do
      @group.stub(:members => @members[0..2])
      @group.group_member_names.should eq "M_1, M_2, M_3"   
    end

    it 'returns empty string if no members' do
      @group.stub(:members => [])
      @group.group_member_names.should eq ""
    end

    it 'ends with elipsis if more members than being printed' do
      @group.stub(:members => @members[0..2])
      @group.group_member_names(2).should match /\.\.\./
    end

    it 'gives count if n > 3' do
      @group.stub(:members => @members[0..5])
      @group.group_member_names(2).should match /6 total/
    end

  end # group_member_names
  
end
