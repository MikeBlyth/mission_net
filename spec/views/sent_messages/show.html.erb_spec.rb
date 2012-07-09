require 'spec_helper'

describe "sent_messages/show" do
  before(:each) do
    @sent_message = assign(:sent_message, stub_model(SentMessage))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
