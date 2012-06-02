require 'spec_helper'

describe "people/index" do
  before(:each) do
    assign(:people, [
      stub_model(Person,
        :last_name => "Last Name",
        :first_name => "First Name",
        :middle_name => "Middle Name",
        :phone_1 => "Phone 1",
        :phone_2 => "Phone 2",
        :email_1 => "Email 1",
        :email_2 => "Email 2",
        :location_id => 1,
        :location_detail => "Location Detail",
        :receive_sms => false,
        :receive_email => false
      ),
      stub_model(Person,
        :last_name => "Last Name",
        :first_name => "First Name",
        :middle_name => "Middle Name",
        :phone_1 => "Phone 1",
        :phone_2 => "Phone 2",
        :email_1 => "Email 1",
        :email_2 => "Email 2",
        :location_id => 1,
        :location_detail => "Location Detail",
        :receive_sms => false,
        :receive_email => false
      )
    ])
  end

  it "renders a list of people" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Last Name".to_s, :count => 2
    assert_select "tr>td", :text => "First Name".to_s, :count => 2
    assert_select "tr>td", :text => "Middle Name".to_s, :count => 2
    assert_select "tr>td", :text => "Phone 1".to_s, :count => 2
    assert_select "tr>td", :text => "Phone 2".to_s, :count => 2
    assert_select "tr>td", :text => "Email 1".to_s, :count => 2
    assert_select "tr>td", :text => "Email 2".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Location Detail".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
