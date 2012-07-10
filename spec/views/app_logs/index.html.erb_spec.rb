require 'spec_helper'

describe "app_logs/index" do
  before(:each) do
    assign(:app_logs, [
      stub_model(AppLog),
      stub_model(AppLog)
    ])
  end

  it "renders a list of app_logs" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
