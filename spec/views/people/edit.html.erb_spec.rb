require 'spec_helper'

describe "people/edit" do
  before(:each) do
    @person = assign(:person, stub_model(Person,
      :last_name => "MyString",
      :first_name => "MyString",
      :middle_name => "MyString",
      :phone_1 => "MyString",
      :phone_2 => "MyString",
      :email_1 => "MyString",
      :email_2 => "MyString",
      :location_id => 1,
      :location_detail => "MyString",
      :receive_sms => false,
      :receive_email => false
    ))
  end

  it "renders the edit person form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => people_path(@person), :method => "post" do
      assert_select "input#person_last_name", :name => "person[last_name]"
      assert_select "input#person_first_name", :name => "person[first_name]"
      assert_select "input#person_middle_name", :name => "person[middle_name]"
      assert_select "input#person_phone_1", :name => "person[phone_1]"
      assert_select "input#person_phone_2", :name => "person[phone_2]"
      assert_select "input#person_email_1", :name => "person[email_1]"
      assert_select "input#person_email_2", :name => "person[email_2]"
      assert_select "input#person_location_id", :name => "person[location_id]"
      assert_select "input#person_location_detail", :name => "person[location_detail]"
      assert_select "input#person_receive_sms", :name => "person[receive_sms]"
      assert_select "input#person_receive_email", :name => "person[receive_email]"
    end
  end
end
