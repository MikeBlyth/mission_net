require 'spec_helper'

describe "app_logs/new" do
  before(:each) do
    assign(:app_log, stub_model(AppLog).as_new_record)
  end

  it "renders new app_log form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => app_logs_path, :method => "post" do
    end
  end
end
