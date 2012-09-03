describe DirectoryDoc do
  include SimTestHelper

  describe "Report" do
    before(:each) do
      @location = FactoryGirl.build(:location, :description=>'Paris')
      @wife = FactoryGirl.build(:member, :short_name => 'Jill')
      @husband = FactoryGirl.build_stubbed(:member, :short_name => 'Jack',
                :in_country => true,
                :location => @location,
                :arrival_date => Date.today - 1.week,
                :departure_date => Date.today + 5.years)
      
      @wife.stub(:husband => @husband)
      @husband.stub(:wife => @wife)
      @single = FactoryGirl.build_stubbed(:member, :short_name => 'Single')
      @families = [@husband, @single]
      @table = DirectoryDoc.new  # Empty report
    end


    it "lists members & spouses" do
      pdf = @table.to_pdf @families, nil, :report_sorted_by_name => true
      report = pdf_string_to_text_string(pdf) # Report based on single family
      report.should match(@husband.last_name)
      report.should match(@wife.short_name)
      report.should match(@single.short_name)
    end

    it "lists by location" do
      pdf = @table.to_pdf @families, nil, :report_sorted_by_location => true
      report = pdf_string_to_text_string(pdf) # Report based on single family
      report.should match(@husband.last_name)
      report.should match(@wife.short_name)
      report.should match(@single.short_name)
      report.should match(@location.description)
    end


  end # check before destroy
      
end

