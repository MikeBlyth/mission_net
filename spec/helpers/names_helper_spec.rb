describe NameHelper do
extend NameHelper

  let(:full) { Member.new(:last_name=>'Last', :first_name=>'First', :middle_name=>'Middle', :short_name=>'Short')}
  let(:first_last) { Member.new(:last_name=>'Last', :first_name=>'First')}
  let(:last_only) { Member.new(:last_name=>'Last')}
  let(:first_only) { Member.new(:first_name=>'First')}
  let(:first_middle_last) { Member.new(:last_name=>'Last', :first_name=>'First', :middle_name=>'Middle')}
  
  describe 'Handles to_s' do
    
    it 'returns last name when first name is nil' do
      last_only.to_s.should eq "Last"
    end

    it 'returns first name when last name is nil' do 
      first_only.to_s.should eq "First"
    end

  end

  describe 'generates shorter name (first name initial + last name)' do

    it 'uses short name if present' do
      full.shorter_name.should eq 'S Last'
    end
    
    it 'uses first name if short name not present' do
      first_last.shorter_name.should eq 'F Last'
    end
    
    it 'handles missing first name' do
      last_only.shorter_name.should eq "Last"
    end
    
  end

  describe 'full name' do

    it 'combines all three names' do
      full.full_name.should eq 'First Middle Last'
    end
    
    it 'gives last name only if others missing' do
      last_only.full_name.should eq 'Last'
    end
    
  end
  
  describe 'full_name_short gives {short | first} last' do
    it 'uses short name' do
      full.full_name_short.should eq 'Short Last'
    end
    
    it 'uses first name' do
      first_last.full_name_short.should eq 'First Last'
    end
    
    it 'uses last only' do
      last_only.full_name_short.should eq 'Last'
    end
    
    it 'uses first only' do
      first_only.full_name_short.should eq 'First'
    end
  end
end
