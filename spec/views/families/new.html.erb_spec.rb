require 'spec_helper'

describe "families/new" do
  before(:each) do
    assign(:family, stub_model(Family).as_new_record)
  end

  it "renders new family form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => families_path, :method => "post" do
    end
  end
end
