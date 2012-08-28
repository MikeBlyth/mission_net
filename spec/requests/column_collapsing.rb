require 'spec_helper'

describe "Members" do
  describe "showing/hiding columns:" do
    
    it 'starts with partial selection of columns' do
       member = integration_test_sign_in(:moderator) # This also puts member into "Group 1"
       save_and_open_page
    end

#ActiveSupport::Deprecation.silence do
  end # showing/hiding columns:
end  
