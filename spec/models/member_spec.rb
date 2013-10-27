require 'spec_helper'
require 'sim_test_helper'
include SimTestHelper
include MembersHelper
require 'application_helper'
#require 'timecop.rb'

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

  end # basic validation

  it 'formats phone numbers before save' do
    @member = FactoryGirl.create(:member, :phone_1 => '08033333333', :phone_2 => '+234816-555.55 55')
    @member.reload.phone_1.should eq '2348033333333'
    @member.reload.phone_2.should eq '2348165555555'
  end
  
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

    it 'finds by last name' do  # searching for ONE of last name, first name, full name
      Member.find_with_name(@member.last_name).should == [@member]
    end

    it 'finds by first name' do  # searching for ONE of last name, first name, full name
      Member.find_with_name(@member.first_name).should == [@member]
    end

    it 'finds by [full] name' do  # searching for ONE of last name, first name, full name
      Member.find_with_name(@member.name).should == [@member]
    end

    it 'finds "last_name, first_name"' do  # when this is different from stored full name (#name)
      @member.update_attribute(:name,"xxxx")  # since we're not relying on this
      Member.find_with_name("#{@member.last_name}, #{@member.first_name}").should == [@member]
    end
      
    it 'finds "last_name, initial"' do  
      Member.find_with_name("#{@member.last_name}, #{@member.first_name[0]}").should == [@member]
    end
    
    it 'finds "short_name last_name"' do  
      Member.find_with_name("#{@member.short_name} #{@member.last_name}").should == [@member]
    end
    
    it 'finds "last_name, short_name"' do  
      Member.find_with_name("#{@member.last_name}, #{@member.short_name}").should == [@member]
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

  describe 'finds members by email' do
    it 'using email_1' do
      email = 'sample@test.com'
      member = FactoryGirl.create(:member, :email_1 => email)
      Member.find_by_email(email).should == [member]
    end

    it 'using email_2' do
      email = 'sample@test.com'
      member = FactoryGirl.create(:member, :email_2 => email)
      Member.find_by_email(email).should == [member]
    end
    
    it 'when two share same address' do
      email = 'sample@test.com'
      member = FactoryGirl.create(:member, :email_1 => 'something else', :email_2 => email)
      member2 = FactoryGirl.create(:member, :email_1 => email)
      unrelated = FactoryGirl.create(:member, :email_1 => 'watermelon')
      Member.find_by_email(email).should include member
      Member.find_by_email(email).should include member2
      Member.find_by_email(email).should_not include unrelated
    end
      
  end
  
  describe 'finds members by phone' do
    before(:each) do
      @phone = std_phone '2345551112222'
    end

    it 'using phone_1' do
      member = FactoryGirl.create(:member, :phone_1 => @phone)
      Member.find_by_phone(@phone).should == [member]
    end

    it 'using phone_2' do
      member = FactoryGirl.create(:member, :phone_2 => @phone)
      Member.find_by_phone(@phone).should == [member]
    end
    
    it 'when two share same number' do
      member = FactoryGirl.create(:member, :phone_1 => 'something else', :phone_2 => @phone)
      member2 = FactoryGirl.create(:member, :phone_1 => @phone)
      unrelated = FactoryGirl.create(:member, :phone_1 => 'watermelon')
      Member.find_by_phone(@phone).should include member
      Member.find_by_phone(@phone).should include member2
      Member.find_by_phone(@phone).should_not include unrelated
    end
      
  end
  
  describe 'spouses' do
    it 'correctly relates husband and wife' do
      @husband = FactoryGirl.create(:member)
      @wife = FactoryGirl.create(:member)
      @husband.update_attributes(:wife => @wife)
      @husband.wife.should == @wife
      @husband.husband.should be_nil
      @wife.husband.should == @husband
      @wife.wife.should be_nil
    end
  end
      

  describe 'contact information' do
    before(:each) do
      @member = FactoryGirl.build(:member)
    end
  
    describe 'contact_summary hash' do

      it 'includes phone and email' do
        summary = @member.contact_summary
        summary['Phone'].should match format_phone(@member.phone_1)
        summary['Phone'].should match format_phone(@member.phone_2)
        summary['Email'].should match @member.email_1
        summary['Email'].should match @member.email_2
      end  

      it 'hides private phone number' do
        @member.phone_private = true
        @member.contact_summary['Phone'].should_not match @member.phone_1
        @member.contact_summary['Phone'].should_not match @member.phone_2
      end

      it 'hides private email address' do
        @member.email_private = true
        @member.contact_summary['Email'].should_not match @member.email_1
        @member.contact_summary['Email'].should_not match @member.email_2
      end

      it 'shows private phone number if override_private is selected' do
        @member.phone_private = true
        @member.contact_summary(:override_private=>true)['Phone'].should match format_phone @member.phone_1
        @member.contact_summary(:override_private=>true)['Phone'].should match format_phone @member.phone_2
        @member.contact_summary(:override_private=>true)['Phone'].should match 'private'
      end

      it 'shows private email if override_private is selected' do
        @member.email_private = true
        @member.contact_summary(:override_private=>true)['Email'].should match @member.email_1
        @member.contact_summary(:override_private=>true)['Email'].should match @member.email_2
        @member.contact_summary(:override_private=>true)['Email'].should match 'private'
      end

      describe "combining couple's data" do

        def phones_formatted(p)
          @member.phone_1, @member.phone_2, @wife.phone_1, @wife.phone_2 = p
          return family_data_formatted(@member)[:phones]
        end
        
        before(:each) do
          @phones = ['2341111111111', '2342222222222', '2343333333333', '2344444444444']
          @formatted = @phones.map {|p| format_phone(p)}
          @formatted_w_names = "#{@formatted[0]} (#{@member.short_name})"
          @wife = FactoryGirl.build_stubbed(:member, :short_name=>'Pixie')
          @member = FactoryGirl.build_stubbed(:member)
          @member.stub(:wife=>@wife)
          @formatted_w_names = ["#{@formatted[0]} (#{@member.short_name})",
                                "#{@formatted[1]} (#{@member.short_name})",
                                "#{@formatted[2]} (#{@wife.short_name})",
                                "#{@formatted[3]} (#{@wife.short_name})"
                                ]
          @both = I18n.t(:both_have_phone)
          @private = I18n.t(:private_dir)
        end

        it 'setup tests ok' do
          result = phones_formatted @phones
          [@member.phone_1, @member.phone_2, @member.wife.phone_1, @member.wife.phone_2].should == @phones
        end

        it 'returns single phone for single member' do
          @phones = @phones[0]
          @member.stub(:wife=>nil)
          phones_formatted(@phones).should eq @formatted[0..0]
        end

        it "returns two phones for single member" do
          @member.stub(:wife=>nil)
          phones_formatted(@phones).should eq @formatted[0..1]
        end          

        it 'returns two phones for wife' do
          @phones[0] = @phones[1] = nil
          phones_formatted(@phones).should eq @formatted_w_names[2..3]
        end

        it 'returns one phone each for husband and wife' do
          @phones[1] = @phones[3] = nil
          phones_formatted(@phones).should eq [@formatted_w_names[0], @formatted_w_names[2]]
        end

        it 'returns two phones each for husband and wife' do
          phones_formatted(@phones).should eq @formatted_w_names
        end

        it 'returns "both" when one phone belongs to both' do
          @phones[3] = @phones[1]
          phones_formatted(@phones).should eq [@formatted_w_names[0], "#{@formatted[1]} #@both", @formatted_w_names[2]]
        end

        it "returns private-string when member's phone is private" do
          @member.phone_private = true
          phones_formatted(@phones).should eq ["#@private (#{@member.short_name})", @formatted_w_names[2], @formatted_w_names[3]]
        end

        it "returns private-string when wife's phone is private" do
          @wife.phone_private = true
          phones_formatted(@phones).should eq [@formatted_w_names[0], @formatted_w_names[1],"#@private (#{@wife.short_name})"]
        end

        it "returns only private-string when both phones are private" do
          @wife.phone_private = true
          @member.phone_private = true
          phones_formatted(@phones).should eq ["#@private #@both"]
        end

      end # combining couple's data

    end # 'contact_summary hash'

    describe 'contact_summary_text' do
      it 'includes phone and email' do
        summary = @member.contact_summary_text
        summary.should match format_phone @member.phone_1
        summary.should match format_phone @member.email_1
      end
    end # 'contact_summary_text'
  end   # contact information 

  describe 'finds those in country' do
    
    it 'checks the "in country" field' do
      @member = FactoryGirl.create(:member, :in_country => true)
      @member_ooc = FactoryGirl.create(:member, :in_country => false)
      Member.those_in_country.should == [@member]
    end
  end
      
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
  
  describe 'Calculating in-country status' do
    before(:each) do
      @member = FactoryGirl.build_stubbed(:member, :in_country=>true, :departure_date => nil, :arrival_date => nil)
    end
    
    describe 'when dates frame an in-country period' do
      it 'returns False when in-country interval is exceeded' do
        @member.departure_date = Date.today - 2.days
        @member.arrival_date = Date.today - 20.days
        @member.calculate_in_country_status.should == [false, nil, nil]
      end
        
      it 'returns true when today falls during in-country interval' do
        @member.in_country = false
        @member.departure_date = Date.today + 2.days
        @member.arrival_date = Date.today - 20.days
        @member.calculate_in_country_status.should == [true, @member.departure_date, @member.arrival_date]
      end
        
      it "doesn't change anything when in-country interval is in the future" do
        @member.departure_date = Date.today + 20.days
        @member.arrival_date = Date.today + 2.days
        @member.calculate_in_country_status.should == [true, @member.departure_date, @member.arrival_date]
      end
    end # when dates frame an in-country period
      
    describe 'when dates frame an out-of-country period' do
      it 'returns true when out-of-country interval is exceeded' do
        @member.arrival_date = Date.today - 2.days
        @member.departure_date = Date.today - 20.days
        @member.calculate_in_country_status.should == [true, nil, @member.arrival_date]
      end
        
      it 'returns false when today falls during out-of-country interval' do
        @member.arrival_date = Date.today + 2.days
        @member.departure_date = Date.today - 20.days
        @member.calculate_in_country_status.should == [false, @member.departure_date, @member.arrival_date]
      end
        
      it "doesn't change anything when out-of-country interval is in the future" do
        @member.arrival_date = Date.today + 20.days
        @member.departure_date = Date.today + 2.days
        @member.in_country = false  # Should remain false even though logically person is in the country
        @member.calculate_in_country_status.should == [false, @member.departure_date, @member.arrival_date]
      end
    end # when dates frame an in-country period
      
    describe 'when only departure date is given' do
      it 'returns no change when departure date is in the future' do
        @member.in_country = false  # Should remain false if set, even though logically person is in the country
        @member.departure_date = Date.today + 20.days
        @member.calculate_in_country_status.should == [false, @member.departure_date, nil]
      end
        
      it 'returns false when departure date is in the past' do
        @member.departure_date = Date.today - 20.days
        @member.calculate_in_country_status.should == [false, @member.departure_date, nil]
      end
    end # when only departure date is given
        
    describe 'when only arrival date is given' do
      it 'returns no change when arrival date is in the future' do
        @member.in_country = true  # Should remain true if set, even though logically person is not yet in the country
        @member.arrival_date = Date.today + 20.days
        @member.calculate_in_country_status.should == [true, nil, @member.arrival_date]
      end
        
      it 'returns true when arrival date is in the past' do
        @member.in_country = false
        @member.arrival_date = Date.today - 20.days
        @member.calculate_in_country_status.should == [true, nil, @member.arrival_date]
      end
        
    end # when only arrival date is given
      
    describe 'updating in_country status for one record' do
      
      it 'performs update if SiteSetting.auto_update_in_country_status is true' do
        @member.stub(:calculate_in_country_status => [true, nil, @member.arrival_date])
        @member.should_receive(:save)
        @member.auto_update_in_country_status(true)
      end

      it 'does not perform update if SiteSetting.auto_update_in_country_status is false' do
        @member.stub(:calculate_in_country_status => [true, nil, @member.arrival_date])
        @member.should_not_receive(:save)
        @member.auto_update_in_country_status(false)
      end
    end # updating in_country status

    describe 'updating in_country status for all records' do
      before(:each) do
        @member.stub(:calculate_in_country_status => [true, nil, @member.arrival_date])
        Member.stub(:all => [@member])
      end        
      
      it 'performs update if SiteSetting.auto_update_in_country_status is true' do
        SiteSetting.stub(:auto_update_in_country_status => '1')
        @member.should_receive(:auto_update_in_country_status).with(true)
        Member.auto_update_all_in_country_statuses
      end

      it 'does not perform update if SiteSetting.auto_update_in_country_status is false' do
        SiteSetting.stub(:auto_update_in_country_status => '0')
        @member.should_receive(:auto_update_in_country_status).with(false)
        Member.auto_update_all_in_country_statuses
      end
    end # updating in_country status
  end

  describe 'Roles (privilege levels):' do
      before(:each) do
        @admin_group = FactoryGirl.build_stubbed(:group, :administrator => true)
        @mod_group = FactoryGirl.build_stubbed(:group, :moderator => true)
        @member_group = FactoryGirl.build_stubbed(:group, :member => true)
        @limited_group = FactoryGirl.build_stubbed(:group, :limited => true)
        @nothing_group = FactoryGirl.build_stubbed(:group)
        @member = FactoryGirl.build_stubbed(:member)
      end

 #     after(:each) {$redis.flushall}  # Clear database if using Redis

    describe 'gets roles from group and follow hierarchy so' do   
      it 'administrator includes all roles' do
        @member.stub(:groups => [FactoryGirl.build_stubbed(:group, :administrator => true)])
        [:administrator, :moderator, :member, :limited].each {|role| @member.roles_include?(role).should be_true}
      end

      it 'moderator includes lower roles' do
        @member.stub(:groups => [FactoryGirl.build_stubbed(:group, :moderator => true)])
        [:moderator, :member, :limited].each {|role| @member.roles_include?(role).should be_true}
        [:administrator].each {|role| @member.roles_include?(role).should be_false}
      end

      it 'member includes lower roles' do
        @member.stub(:groups => [FactoryGirl.build_stubbed(:group, :member => true)])
        [ :member, :limited].each {|role| @member.roles_include?(role).should be_true}
        [:moderator, :administrator].each {|role| @member.roles_include?(role).should be_false}
      end
      
      it 'limited includes no other roles' do
        @member.stub(:groups => [FactoryGirl.build_stubbed(:group, :limited => true)])
        @member.roles_include?(:limited).should be_true
        [:moderator, :administrator, :member].each {|role| @member.roles_include?(role).should be_false}
      end

      it 'member with no privilege has no roles' do
        @member.stub(:groups => [FactoryGirl.build_stubbed(:group)])
        [:administrator, :moderator, :member, :limited].each {|role| @member.roles_include?(role).should be_false}
      end
    end  # gets roles from group and follow hierarchy
    
    describe "gets highest role among the user's groups" do

      def create_role_groups
        [:administrator, :moderator, :member, :limited].each do |role|
          instance_variable_set("@#{role}_group", FactoryGirl.create(:group, :group_name => role.to_s, role => true))
        end
        @no_role_group = FactoryGirl.create(:group, :group_name => 'no_role')
        @administrator_group.administrator.should be_true
      end # build_role_groups

#      before(:each) { $redis.flushall} # may be needed if using Redis
      before(:all) {create_role_groups}
      after(:all) {Group.destroy_all}      
      let(:user) {FactoryGirl.build_stubbed(:member)}

      it "[test creates role groups correctly]" do 
        @administrator_group.administrator.should be_true
        @moderator_group.administrator.should be_false
        @moderator_group.moderator.should be_true
        @member_group.member.should be_true
        @member_group.moderator.should be_false
        @limited_group.limited.should be_true
        @limited_group.member.should be_false
      end  

      describe "finds highest among roles" do
        it '--administrator' do
          user.stub(:groups=> [@administrator_group, @limited_group])
          user.role.should eq :administrator
        end
        it '--moderator' do
          user.stub(:groups => [@moderator_group, @limited_group, @no_role_group])
          user.role.should eq :moderator
        end
        it '--limited' do
          user.stub(:groups => [@limited_group, @no_role_group])
          user.role.should eq :limited
        end
        it '--no group => no role' do
          user.stub(:groups => [])
          user.role.should eq nil
        end  
        it '--groups w/o role => no role' do
          user.stub(:groups => [@no_role_group])
          user.role.should eq nil
        end
      end
      
    end # gets highest role among the user's groups

#    describe 'uses Redis:' do

#      def set_redis_user_role(user, role=nil)
#        key = "user:#{user.id}"
#        $redis.hset(key, :role, role)
#        $redis.expire(key, 5)  # So database is cleaned after the whole run, if not sooner
#      end
#    
#      it 'uses role from Redis when it exists' do
#        user = FactoryGirl.build_stubbed(:member)
#        user.stub(:recalc_highest_role, 'Should not get this!')
#        set_redis_user_role(user, 'cantelope')
#        user.role.should eq :cantelope
#      end
#      
#      it 'uses recalulated role when Redis does not exist' do
#        user = FactoryGirl.build_stubbed(:member)
#        user.stub(:recalc_highest_role => 'Administrator')
#        user.role.should eq :administrator
#      end

#      it 'expires role after one minute' do
#        user = FactoryGirl.build_stubbed(:member)
#        user.stub(:recalc_highest_role => 'Administrator')
#        user.role_cache_duration.should > 10 # Make sure it's in use
#        user.role_cache_duration = 1  # Change duration to 1 sec so we don't have to wait
#        user.role.should eq :administrator
#        $redis.hget("user:#{user.id}", 'role').should eq 'Administrator'
#        sleep(2)
##        Timecop.travel(Time.now + 80.seconds)
#        $redis.hget("user:#{user.id}", 'role').should be_nil
#      end     
#      
#    end # uses Redis
  end  # Roles (privilege levels):

  describe 'Parse_update_command method' do
    let(:member) {FactoryGirl.build_stubbed(:member)}
    let(:member_name) {"#{member.first_name} #{member.last_name}"}
    let(:phone_1){"2342223334444"}
    let(:email_1){"abc@example.com"} 
    let(:phone_2){"2349993334444"}
    let(:email_2){"xyz@example.com"} 
    let(:s){"#{member_name} #{phone_1} #{email_1}"}
    let(:s2){"#{member_name} #{phone_1} #{email_1} #{phone_2} #{email_2}"}

    context 'when member is not found' do  
      before(:each) do
        Member.should_receive(:find_with_name).and_return([]) # i.e., name does not exist in database
      end
      
      it 'returns empty array of members' do
        result = Member.parse_update_command(s)
        result[:members].should be_empty
      end

      it 'returns names hash' do
        s_w_middle = "#{member.first_name} #{member.middle_name} #{member.last_name} #{phone_1} #{email_1}"
        result = Member.parse_update_command(s_w_middle)
        result[:updates][:first_name].should eq member.first_name.gsub('_', ' ')
        result[:updates][:last_name].should eq member.last_name.gsub('_', ' ')
        result[:updates][:middle_name].should eq member.middle_name.gsub('_', ' ')
        result[:updates][:name].should eq "#{member.last_name}, #{member.first_name} #{member.middle_name}".gsub('_', ' ')
      end

      it 'returns phones & emails' do
        result = Member.parse_update_command(s)
        result[:updates][:phone_1].should eq phone_1
        result[:updates][:email_1].should eq email_1
      end
    end
    
    context 'when member is found' do
      before(:each) do
        Member.should_receive(:find_with_name).with(member_name).and_return([member])
      end

      it 'returns non-nil result when member found' do
        result = Member.parse_update_command(s)
        result.should_not be_nil
        result[:members].should eq [member]
      end

      it 'ignores mailto: links after email address' do
        results = Member.parse_update_command(s+"<mailto:xyz@test.com>")
        results.should_not be_nil
        results[:updates][:email_1].should eq email_1
      end
      
      it 'ignores unknown tokens after name is complete' do
        results = Member.parse_update_command(s+" garbage_data")
        # Test is just the Member.should_receive ... in the before(:each) section
      end

      it 'finds phone number to update' do
        results = Member.parse_update_command(s)
        results[:updates][:phone_1].should eq phone_1
      end

      it 'finds phone numbers and email addresses' do
        results = Member.parse_update_command(s2)
        results[:updates][:phone_1].should eq phone_1
        results[:updates][:phone_2].should eq phone_2
        results[:updates][:email_1].should eq email_1
        results[:updates][:email_2].should eq email_2
      end

      describe 'sets groups array' do
        let(:s_groups) {s + " group_1 grp2"}
        before(:all) do
          @group_1 = FactoryGirl.create(:group, :group_name => 'group_1', :abbrev=>'grp1')
          @group_2 = FactoryGirl.create(:group, :group_name => 'group_2', :abbrev=>'grp2')
        end
        after(:all) {Group.destroy_all}
        
        it 'returns array of group ids' do
          results = Member.parse_update_command(s_groups)[:updates][:groups].sort
          expected = [@group_1.id.to_s, @group_2.id.to_s]
 puts "**** s_groups=#{s_groups}"
          results.should eq expected
        end

        it 'includes invalid group name as a string' do
          results = Member.parse_update_command(s_groups + ' bad_name')[:updates][:groups].sort
          expected = [@group_1.id.to_s, @group_2.id.to_s, 'bad_name']
 puts "**** s_groups=#{s_groups}"
          results.should eq expected
        end
  
        it 'returns empty array if no groups specified' do
          results = Member.parse_update_command(s)[:updates][:groups].sort
          expected = []
          results.should eq expected
        end
      end # sets groups array
        
        
    end #when member is found    

    context 'when two members are found' do
      it 'returns both members' do
        second_member = mock('second member')
        Member.should_receive(:find_with_name).with(member_name).
           and_return([member, second_member])
        results = Member.parse_update_command(s)
        results[:members].should eq [member, second_member]      
      end
    end # when two members are found
  end # Parse_update_command method

  describe 'merge_group_ids method yields valid new group_ids' do
    # This method handles the incoming (from form) group ids and only allows changes to
    # the groups allowed for the given user role (privilege).
    let(:member) {FactoryGirl.build_stubbed(:member)}
    let(:selectable) {['11', '12', '13'].to_set}
    before(:each) do  
      member.stub(:group_ids => [1, 11])  # this what groups member appears to belong to
    end             

    context 'by default (merge) removes unselected groups if they are selectable' do
      it 'merges new selectable group' do
        member.merge_group_ids(['1', '11', '12'], {:selectable=>selectable}).
          sort.should eq ['1', '11', '12']
      end
   
      it 'does not merge new non-selectable group' do
        member.merge_group_ids(['1', '2', '11'], {:selectable=>selectable}).
          sort.should eq ['1', '11']
      end
   
      it 'removes selectable group' do
        member.merge_group_ids(['1'], {:selectable=>selectable}).should eq ['1']
      end
      it 'does not remove non-selectable group' do
        member.merge_group_ids([ '11'], {:selectable=>selectable}).sort.should eq ['1', '11']
      end

      it 'merges/removes mix of updates' do
         member.merge_group_ids(['2', '12', '13'], {:selectable=>selectable}).
          sort.should eq ['1', '12', '13']
      end

      it 'returns all group updates when selectable is nil' do
        member.merge_group_ids(['2', '11', '12', '99']).
          to_set.should eq ['2', '11', '12', '99'].to_set
      end
   
      it 'returns unchangeable groups when selected is empty' do
        member.merge_group_ids([], {:selectable=>selectable}).should eq ['1']
        member.merge_group_ids([''], {:selectable=>selectable}).should eq ['1']
      end
    end # by default ... (merge mode)
    
    context 'in add mode, only adds and never removes groups' do
    
      it 'adds selectable groups' do
        member.merge_group_ids(['12', '13'], {:selectable=>selectable, :add=>true}).
          sort.should eq ['1', '11', '12', '13']
      end

      it 'does not add non-selectable groups' do
        member.merge_group_ids(['2', '12'], {:selectable=>selectable, :add=>true}).
          sort.should eq ['1', '11', '12']
      end
    end # in add mode, only...
  end # merge_group_ids method yields valid new group_ids

end

