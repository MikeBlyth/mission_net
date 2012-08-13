class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper  # sign in, sign out, current user, etc.

ActiveRecord::Base.logger.level = Logger::WARN

  ActiveScaffold.set_defaults do |config| 
    config.ignore_columns.add [:created_at, :updated_at, :lock_version]
    config.list.empty_field_text = '----'
    config.security.default_permission = true
    config.security.current_user_method = :current_user
  end

  before_filter :require_https, :except => :update_status_clickatell #, :only => [:login, :signup, :change_password] 
#c#  check_authorization  
  
  def require_https
    redirect_to :protocol => "https://" unless (request.protocol=='https://' or request.host=='localhost' or
        request.host == 'test.host' or 
        request.headers['REQUEST_URI'] =~ /update_status_clickatell/ or
        request.remote_addr == '127.0.0.1')
  end

#c#  rescue_from CanCan::AccessDenied do |exception|
#c#    puts "**** Access denied by CanCan: #{exception.message} ****"# if Rails.env == 'test'
#c#    if !signed_in? 
#c#      redirect_to sign_in_path
#c#      puts "**** Not signed in!"
#c#    else  
#c#      if (request.referer == request.url) # A rare occasion 
#c#        redirect_to safe_page_path
#c#      else
#c#        redirect_to request.referer || safe_page_path, :alert => exception.message
#c#      end
#c#    end
#c#  end

  def iron_worker
    @iron_worker_client ||= IronWorkerNG::Client.new
  end  

  def current_user
    current_user ||= (Member.find(session[:user_id]) if session[:user_id])
    $current_user = current_user
    return current_user
  end

private

  def self.load_and_authorize_resource
  end

  def self.skip_authorization_check
  end

  def authorize
    redirect_to(sign_in_url, :notice => "Please log in") unless signed_in?
  end

end
