require 'spec_helper'

describe "locations/show" do
  before(:each) do
    @location = assign(:location, stub_model(Location,
      :name => "Name",
      :state => "State",
      :city => "City",
      :lga => "Lga",
      :gps_latitude => "",
      :gps_longitude => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/State/)
    rendered.should match(/City/)
    rendered.should match(/Lga/)
    rendered.should match(//)
    rendered.should match(//)
  end
end
