require 'spec_helper'

describe "people/show" do
  before(:each) do
    @person = assign(:person, stub_model(Person,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Last Name/)
    rendered.should match(/First Name/)
    rendered.should match(/Middle Name/)
    rendered.should match(/Phone 1/)
    rendered.should match(/Phone 2/)
    rendered.should match(/Email 1/)
    rendered.should match(/Email 2/)
    rendered.should match(/1/)
    rendered.should match(/Location Detail/)
    rendered.should match(/false/)
    rendered.should match(/false/)
  end
end
