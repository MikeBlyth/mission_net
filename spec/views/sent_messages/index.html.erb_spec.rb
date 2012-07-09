require 'spec_helper'

describe "sent_messages/index" do
  before(:each) do
    assign(:sent_messages, [
      stub_model(SentMessage),
      stub_model(SentMessage)
    ])
  end

  it "renders a list of sent_messages" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
