require 'spec_helper'

describe "sent_messages/edit" do
  before(:each) do
    @sent_message = assign(:sent_message, stub_model(SentMessage))
  end

  it "renders the edit sent_message form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sent_messages_path(@sent_message), :method => "post" do
    end
  end
end
