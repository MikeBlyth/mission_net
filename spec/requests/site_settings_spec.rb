require 'spec_helper'

describe "Site_Settings" do
  
  it "Opens page and saves all settings" do
    integration_test_sign_in(:administrator)
    click_link 'Settings'
    text_boxes = ['sendgrid_user_name', 'sendgrid_password', 'clickatell_user_name',
        'clickatell_password', 'clickatell_api_id', 'twilio_account_sid', 
        'twilio_phone_number', 'contact_update_recipients']
    text_boxes.each do |item|
      fill_in item, :with => item
    end
    select 'Clickatell'
    select 'No'
    select 'Iron'
    click_button 'Save'
    # Check changes
    text_boxes.each {|item| SiteSetting.send(item.to_sym).should eq item}
    SiteSetting.default_outgoing_sms_gateway.should eq 'Clickatell'
    SiteSetting.auto_update_in_country_status.should eq "0"
    SiteSetting.twilio_background.should eq 'IronWorker'
    
  end

end  
