require 'spec_helper'

describe "blood_types/index" do
  before(:each) do
    assign(:blood_types, [
      stub_model(BloodType,
        :abo => "Abo",
        :rh => "Rh",
        :full => "Full"
      ),
      stub_model(BloodType,
        :abo => "Abo",
        :rh => "Rh",
        :full => "Full"
      )
    ])
  end

  it "renders a list of blood_types" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Abo".to_s, :count => 2
    assert_select "tr>td", :text => "Rh".to_s, :count => 2
    assert_select "tr>td", :text => "Full".to_s, :count => 2
  end
end
