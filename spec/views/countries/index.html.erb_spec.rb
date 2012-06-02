require 'spec_helper'

describe "countries/index" do
  before(:each) do
    assign(:countries, [
      stub_model(Country,
        :code => "Code",
        :name => "Name",
        :nationality => "Nationality",
        :include_in_selection => "Include In Selection"
      ),
      stub_model(Country,
        :code => "Code",
        :name => "Name",
        :nationality => "Nationality",
        :include_in_selection => "Include In Selection"
      )
    ])
  end

  it "renders a list of countries" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Code".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Nationality".to_s, :count => 2
    assert_select "tr>td", :text => "Include In Selection".to_s, :count => 2
  end
end
