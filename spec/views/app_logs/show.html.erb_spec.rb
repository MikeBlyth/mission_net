require 'spec_helper'

describe "app_logs/show" do
  before(:each) do
    @app_log = assign(:app_log, stub_model(AppLog))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
