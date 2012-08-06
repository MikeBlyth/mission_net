class SiteSettingsController < ActionController::Base
  protect_from_forgery

#  before_filter :authenticate_admin #, :only => [:edit, :update]
#  include AuthenticationHelper
  include ApplicationHelper
  include SessionsHelper
  load_and_authorize_resource
  
  layout 'application'

  def edit
  end

  def index
  end

  def update
    SiteSetting.keys.each do |key|
      SiteSetting.find_or_create_by_name(key).
                   update_attribute(:value,params[key])
    end
    flash[:notice] = "Settings saved"
    redirect_to site_settings_path
  end
end

