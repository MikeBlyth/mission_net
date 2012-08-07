class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper  # sign in, sign out, current user, etc.


  ActiveScaffold.set_defaults do |config| 
    config.ignore_columns.add [:created_at, :updated_at, :lock_version]
    config.list.empty_field_text = '----'
    config.security.default_permission = false
  end

  before_filter :require_https, :except => :update_status_clickatell #, :only => [:login, :signup, :change_password] 
  check_authorization  
  
  def require_https
    redirect_to :protocol => "https://" unless (request.protocol=='https://' or request.host=='localhost' or
        request.host == 'test.host' or 
        request.headers['REQUEST_URI'] =~ /update_status_clickatell/ or
        request.remote_addr == '127.0.0.1')
  end

  rescue_from CanCan::AccessDenied do |exception|
    puts "**** Access denied by CanCan: #{exception.message} ****"# if Rails.env == 'test'
    if !signed_in? 
      redirect_to sign_in_path
    else  
     if (request.referer == request.url) # A rare occasion 
        redirect_to safe_page_path
      else
        redirect_to request.referer || safe_page_path, :alert => exception.message
      end
    end
  end

  def iron_worker
    @iron_worker_client ||= IronWorkerNG::Client.new
  end  

private

  def authorize
    redirect_to(sign_in_url, :notice => "Please log in") unless signed_in?
  end
  
end
