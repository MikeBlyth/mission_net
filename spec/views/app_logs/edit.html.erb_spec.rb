require 'spec_helper'

describe "app_logs/edit" do
  before(:each) do
    @app_log = assign(:app_log, stub_model(AppLog))
  end

  it "renders the edit app_log form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => app_logs_path(@app_log), :method => "post" do
    end
  end
end
