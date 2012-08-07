require 'spec_helper'

describe SiteSettingsController do

  describe 'Authorization' do
    
    it 'allows administrator to edit settings' do
      user = test_sign_in(:administrator)
      user.is_administrator?.should eq true
      post :edit
    end
  
    it 'does not allow moderator to edit settings' do
      user = test_sign_in(:moderator)
      lambda {post :edit}.should raise_error(StandardError, /not authorized/i)
    end
  
  end

  
end
