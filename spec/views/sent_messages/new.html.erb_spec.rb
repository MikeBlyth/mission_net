require 'spec_helper'

describe "sent_messages/new" do
  before(:each) do
    assign(:sent_message, stub_model(SentMessage).as_new_record)
  end

  it "renders new sent_message form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sent_messages_path, :method => "post" do
    end
  end
end
