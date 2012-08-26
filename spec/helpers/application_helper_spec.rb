describe ApplicationHelper do
extend ApplicationHelper

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
  
  
end
