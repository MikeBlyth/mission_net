#require "~/joslink/app/helpers/application_helper.rb"

describe ApplicationHelper do
#extend ApplicationHelper

  describe 'Phone formatting' do
    
    it 'formats Nigerian numbers (+234..., 234...) to local form' do
      format_phone('+2348033854268').should == '0803 385 4268'
      format_phone('2348033854268').should == '0803 385 4268'
    end

    it 'formats 11-digits starting with 0 to local form' do
      format_phone('08033854268').should == '0803 385 4268'
      format_phone('0803-385-4268').should == '0803 385 4268'
    end

    it 'removes junk in presumed Nigerian numbers' do
      format_phone('0803385 426ext8 ').should == '0803 385 4268'
    end
        
    it 'does not remove junk in other numbers' do
      format_phone('1803385 426ext8 ').should == '1803385 426ext8 '
    end

    it 'does not change 11-digit numbers not starting with 0' do
      format_phone('18033854268').should == '18033854268'
    end

    it 'does not change non-11-digit numbers starting with 0' do
      format_phone('018033854268').should == '018033854268'
    end

  end

  describe 'phone_std converts to canonical form' do
    
    it 'replaces leading zero with country code' do
      std_phone('08033854268').should eq '2348033854268'
    end

    it 'removes leading plus sign' do
      std_phone('+2348033854268').should eq '2348033854268'
    end

    it 'removes parens, hyphen, space and period' do
      std_phone('(+234) 803-38.5 4268').should eq '2348033854268'
    end

  end

  describe 'various tools:' do
    
    describe 'description_or_blank' do
    
      it 'returns description when object exists' do
        obj = mock('Object', :description => 'OK')
        description_or_blank(obj).should eq 'OK'
      end

      it 'returns empty string by default when object does not exist' do
        description_or_blank(nil).should eq ''
      end

      it 'returns empty string by default when description does not exist' do
        obj = mock('Object')
        description_or_blank(nil).should eq ''
      end

      it 'returns value of another method/column when specified' do
        obj = mock('Object', :description => 'wrong one', :custom => 'OK')
        description_or_blank(obj, '', :custom).should eq 'OK'
      end

      it 'returns different nil value when specified' do
        obj = FactoryGirl.build_stubbed(:member)
        description_or_blank(obj, '*empty*', :unknown_column).should eq '*empty*'
      end
    end # description or blank

    describe 'method_or_key' do

      it 'returns method result when method exists' do
        s = "5"
        method_or_key(s, :to_i).should eq 5
      end

      it 'returns hash result when it exists' do
        method_or_key({:k=> 'value'}, :k).should eq 'value'
        method_or_key({'k'=> 'value'}, :k).should eq 'value'
        method_or_key({:k => 'value'}, 'k').should eq 'value'
        method_or_key({'k'=> 'value'}, 'k').should eq 'value'
      end

    end # method or key

    describe 'same_date' do
      it 'returns correct date comparison' do
        obj = FactoryGirl.build_stubbed(:member, :arrival_date => Date.new(2008, 10, 5))
        same_date(obj, '2008-10-05', :arrival_date).should be_true
        same_date(obj, '5 Oct 08', :arrival_date).should be_true
        same_date(obj, '5 October 2008', :arrival_date).should be_true
        same_date(obj, 'Oct 5, 2008', :arrival_date).should be_true
        same_date(obj, '6 Oct 08', :arrival_date).should be_false
        same_date(obj, '2008-10-06', :arrival_date).should be_false
      end        
    end # same_date

    describe 'smart_join' do
      it 'joins array members as specified' do
        smart_join([' a ', '', nil, 3.5, "25\n"]).should eq "a, 3.5, 25" 
      end
    end

    it 'link_ids works' do
      link_id('a').should eq 'a_id'
      link_id('a_id').should eq 'a_id'
      link_id(:a_id).should eq :a_id
      link_id(:a).should eq :a_id
    end
    
    it 'Array.not_blank works' do
      a = [1, '', nil, 2, 3, '']
      original_a = a.clone
      a.not_blank.should eq [1, 2, 3]
      a.should eq original_a  # Not changed by method
      a.not_blank!.should eq [1, 2, 3]
      a.should eq [1, 2, 3]  # Changed
    end

    describe 'Clean old file entries' do
      before(:each) do
        # Build 10 records whose :created_at dates increment 1 day each.
        model = (1..10).map {|i| FactoryGirl.build(:app_log)}
        ActiveRecord::Base.transaction do
          model.each {|m| m.save}
        end        
        ActiveRecord::Base.transaction do
          i = 0
          model.each do |m| 
            i+=1
            m.created_at = Date.new(2000,1,i) + 10.hours
            m.save
          end
        end
      end

      it 'deletes entries before a given date' do
          clean_old_file_entries(AppLog, :before_date => Date.new(2000,1,6))
          AppLog.count.should eq 5
      end
      it 'deletes entries to leave a fixed remaining number' do
          clean_old_file_entries(AppLog, :max_to_keep => 5)
          AppLog.count.should eq 5
      end
      it 'deletes entries before a given date' do
      end
    end # 
  end  # various tools
  
    
  
end
