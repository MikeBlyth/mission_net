require 'spec_helper'

describe "families/edit" do
  before(:each) do
    @family = assign(:family, stub_model(Family))
  end

  it "renders the edit family form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => families_path(@family), :method => "post" do
    end
  end
end
