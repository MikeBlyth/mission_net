require 'spec_helper'


describe "Members" do
  describe "GET /members" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      integration_test_sign_in
puts "**** after sign in,"       
page.should have_content 'Signed in as test'
#      get members_path
#binding.pry  
#      response.status.should be(200)
    end
  end
end
