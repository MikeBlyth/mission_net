require 'spec_helper'

describe "blood_types/new" do
  before(:each) do
    assign(:blood_type, stub_model(BloodType,
      :abo => "MyString",
      :rh => "MyString",
      :full => "MyString"
    ).as_new_record)
  end

  it "renders new blood_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => blood_types_path, :method => "post" do
      assert_select "input#blood_type_abo", :name => "blood_type[abo]"
      assert_select "input#blood_type_rh", :name => "blood_type[rh]"
      assert_select "input#blood_type_full", :name => "blood_type[full]"
    end
  end
end
