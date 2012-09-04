describe ModelHelper do
extend ModelHelper

  describe 'check_for_linked_records' do

    it 'prevents deletion of record with children' do
      city = FactoryGirl.build_stubbed(:city)
      city.should be_valid
      city.stub(:locations => [mock('Location')])
      city.check_for_linked_records.should be_false
      city.errors[:base].to_s.should match /location.* City still exist/
    end

    it 'allows deletion of record with no children' do
      city = FactoryGirl.build_stubbed(:city)
      city.should be_valid
      city.stub(:locations => [])
      city.check_for_linked_records.should be_true
      city.errors[:base].should be_empty
    end

  end
  
end
