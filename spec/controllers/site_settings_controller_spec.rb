require 'spec_helper'

describe SiteSettingsController do

  describe 'Authorization' do
    
    it 'allows administrator to edit settings' do
      user = test_sign_in(:administrator)
      user.role.should eq :administrator
      post :edit
    end
  
    it 'does not allow moderator to edit settings' do
      user = test_sign_in(:moderator)
      post :edit
      flash[:alert].should =~ /not authorized/i    
    end
  
  end
end
