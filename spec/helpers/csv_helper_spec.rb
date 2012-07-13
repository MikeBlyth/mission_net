describe ExportHelper do
extend ExportHelper
  
  describe 'export_csv' do
    it 'builds a export csv string' do
      @member = FactoryGirl.build(:member)
      csv = export_csv([@member],%w{last_name phone_1})
      csv.should match(@member.last_name)
      csv.should match(@member.phone_1)
    end
  end
  
end
