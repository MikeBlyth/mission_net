require 'spec_helper'
### THESE TESTS WERE GENERATED AUTOMATICALLY AND MAY NEED MORE TWEAKING
describe "locations/index" do
  before(:each) do
    assign(:locations, [
      stub_model(Location,
        :name => "Name",
        :state => "State",
        :city => "City",
        :lga => "Lga",
        :gps_latitude => 10.0,
        :gps_longitude => 9.0
      ),
      stub_model(Location,
        :name => "Name",
        :state => "State",
        :city => "City",
        :lga => "Lga",
        :gps_latitude => 10.0,
        :gps_longitude => 9.0
      )
    ])
  end

  it "renders a list of locations" do
    render
    puts rendered()
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "State".to_s, :count => 2
    assert_select "tr>td", :text => "City".to_s, :count => 2
    assert_select "tr>td", :text => "Lga".to_s, :count => 2
    assert_select "tr>td", :text => "10.0".to_s, :count => 2
    assert_select "tr>td", :text => "9.0".to_s, :count => 2
  end
end
