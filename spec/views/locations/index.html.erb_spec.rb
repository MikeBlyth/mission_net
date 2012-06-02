require 'spec_helper'

describe "locations/index" do
  before(:each) do
    assign(:locations, [
      stub_model(Location,
        :name => "Name",
        :state => "State",
        :city => "City",
        :lga => "Lga",
        :gps_latitude => "",
        :gps_longitude => ""
      ),
      stub_model(Location,
        :name => "Name",
        :state => "State",
        :city => "City",
        :lga => "Lga",
        :gps_latitude => "",
        :gps_longitude => ""
      )
    ])
  end

  it "renders a list of locations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "State".to_s, :count => 2
    assert_select "tr>td", :text => "City".to_s, :count => 2
    assert_select "tr>td", :text => "Lga".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
