require 'spec_helper'

describe "groups/index" do
  before(:each) do
    assign(:groups, [
      stub_model(Group,
        :group_name => "Group Name",
        :parent_group_id => 1,
        :abbrev => "Abbrev",
        :primary => false
      ),
      stub_model(Group,
        :group_name => "Group Name",
        :parent_group_id => 1,
        :abbrev => "Abbrev",
        :primary => false
      )
    ])
  end

  it "renders a list of groups" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Group Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Abbrev".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
