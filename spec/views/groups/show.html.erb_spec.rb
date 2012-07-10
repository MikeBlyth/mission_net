require 'spec_helper'

describe "groups/show" do
  before(:each) do
    @group = assign(:group, stub_model(Group,
      :group_name => "Group Name",
      :parent_group_id => 1,
      :abbrev => "Abbrev",
      :primary => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Group Name/)
    rendered.should match(/1/)
    rendered.should match(/Abbrev/)
    rendered.should match(/false/)
  end
end
