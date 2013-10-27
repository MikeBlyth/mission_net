describe NameHelper do
extend NameHelper

  describe 'Handles to_s' do
    
    it 'returns a name when last name is nil' do
      @member = Member.new(:last_name => "A")
      @member.to_s.should eq "A"
    end

    it 'returns a name when first name is nil' do
      @member = Member.new(:first_name => "A")
      @member.to_s.should eq "A"
    end

  end

  describe 'generates short name' do
    before(:each) {@member = Member.new(:last_name => "Last", :first_name => 'First', :short_name => 'Short') }
    it 'uses short name if present' do
      @member.short.should eq 'Short'
    end
    
    it 'uses first name if short name not present' do
      @member.short_name = nil
      @member.short.should eq 'First'
    end
    
    it 'uses first name if short name is blank' do
      @member.short_name = ''
      @member.short.should eq 'First'
    end
    
    it 'handles missing first name' do
      @member = Member.new(:last_name => "A")
      @member.short.should eq "-"
    end
  end
  
end
