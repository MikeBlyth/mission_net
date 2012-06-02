require 'spec_helper'

describe "countries/show" do
  before(:each) do
    @country = assign(:country, stub_model(Country,
      :code => "Code",
      :name => "Name",
      :nationality => "Nationality",
      :include_in_selection => "Include In Selection"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Code/)
    rendered.should match(/Name/)
    rendered.should match(/Nationality/)
    rendered.should match(/Include In Selection/)
  end
end
