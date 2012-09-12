class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper  # sign in, sign out, current user, etc.


  ActiveScaffold.set_defaults do |config| 
    config.ignore_columns.add [:created_at, :updated_at, :lock_version]
    config.list.empty_field_text = '----'
    config.security.default_permission = false
    config.security.current_user_method = :current_user
  end

  before_filter :require_https, :except => :update_status_clickatell #, :only => [:login, :signup, :change_password] 
  check_authorization  

  before_filter :set_locale
  
  def require_https
    redirect_to :protocol => "https://" unless (request.protocol=='https://' or request.host=='localhost' or
        request.host == 'test.host' or 
        request.headers['REQUEST_URI'] =~ /update_status_clickatell/ or
        request.remote_addr == '127.0.0.1')
  end

  def default_url_options(options={})
#    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { :locale => I18n.locale }
  end

  rescue_from CanCan::AccessDenied do |exception|
    puts "**** Access denied by CanCan: #{exception.message} ****"# if Rails.env == 'test'
    if !signed_in? 
      redirect_to sign_in_path
      puts "**** Not signed in!"
    else  
      if response.request.fullpath =~ /inline_adapter/
        render :json => "<em>#{t('cancan_forbidden')}</em>".html_safe
        return
      end
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

  def current_user
    current_user ||= (Member.find(session[:user_id]) if session[:user_id])
    $current_user = current_user
    return current_user
  end

private

  def set_locale
    locale = (params[:locale] || 'en').to_sym
    if I18n.available_locales.include? locale
      I18n.locale = locale
    end
  end

  def authorize
    redirect_to(sign_in_url, :notice => t("Please log in")) unless signed_in?
  end

end
