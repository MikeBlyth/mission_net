require 'spec_helper'

describe "groups/edit" do
  before(:each) do
    @group = assign(:group, stub_model(Group,
      :group_name => "MyString",
      :parent_group_id => 1,
      :abbrev => "MyString",
      :primary => false
    ))
  end

  it "renders the edit group form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => groups_path(@group), :method => "post" do
      assert_select "input#group_group_name", :name => "group[group_name]"
      assert_select "input#group_parent_group_id", :name => "group[parent_group_id]"
      assert_select "input#group_abbrev", :name => "group[abbrev]"
      assert_select "input#group_primary", :name => "group[primary]"
    end
  end
end
