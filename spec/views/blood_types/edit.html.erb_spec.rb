require 'spec_helper'

describe "blood_types/edit" do
  before(:each) do
    @blood_type = assign(:blood_type, stub_model(BloodType,
      :abo => "MyString",
      :rh => "MyString",
      :full => "MyString"
    ))
  end

  it "renders the edit blood_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => blood_types_path(@blood_type), :method => "post" do
      assert_select "input#blood_type_abo", :name => "blood_type[abo]"
      assert_select "input#blood_type_rh", :name => "blood_type[rh]"
      assert_select "input#blood_type_full", :name => "blood_type[full]"
    end
  end
end
