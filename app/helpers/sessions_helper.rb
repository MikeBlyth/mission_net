module SessionsHelper

  def current_user
    @current_user ||= (Member.find(session[:user_id]) if session[:user_id])
  end

  def current_user_role
    @current_user_role ||= current_user.recalc_highest_role
  end

  # Is user (the parameter) the currently logged in user?
  def current_user?(user)
    user == current_user
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    session[:user_id] = nil
    self.current_user = nil
  end

  def login_allowed(user_email)
    members_with_email = Member.find_by_email(user_email)
    # Have to go through each group in priority order so that we return the member with the highest privileges
    members_with_email.each {|m| return m if m.role == :administrator}
    members_with_email.each {|m| return m if m.role == :moderator}
    members_with_email.each {|m| return m if m.role == :member}
    members_with_email.each {|m| return m if m.role == :limited}
    AppLog.create(:code=>'Login', :severity => 'Warning', :description => "Login attempted with email #{user_email} but was rejected.")
    # Uncomment next line if you want users with "limited" privileges to be able to log in to web interface
    # members_with_email.each {|m| return m if limited?(m)}
    return false
  end

  def deny_access
    redirect_to sign_in_path, :notice => I18n.t("Please log in")
  end
end
