class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper  # sign in, sign out, current user, etc.

  ActiveScaffold.set_defaults do |config| 
    config.ignore_columns.add [:created_at, :updated_at, :lock_version]
    config.list.empty_field_text = '----'
  end

  before_filter :require_https, :except => :update_status_clickatell #, :only => [:login, :signup, :change_password] 
  before_filter :authorize

  def require_https
    redirect_to :protocol => "https://" unless (request.protocol=='https://' or request.host=='localhost' or
        request.host == 'test.host' or 
        request.headers['REQUEST_URI'] =~ /update_status_clickatell/ or
        request.remote_addr == '127.0.0.1')
  end

  def iron_worker
    @iron_worker_client ||= IronWorkerNG::Client.new
  end  

private

  def authorize
    redirect_to(sign_in_url, :notice => "Please log in") unless signed_in?
  end
  
  def authorize_privilege(privilege = :member)
    redirect_to signin_path if !signed_in? 
    redirect_to request.referer, :alert => exception.message unless current_user.has_privilege(privilege)
  end    
end
