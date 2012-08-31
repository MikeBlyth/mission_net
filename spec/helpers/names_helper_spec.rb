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
  
end
