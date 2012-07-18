module SessionsHelper
  def current_user
    @current_user ||= (Member.find(session[:user_id]) if session[:user_id])
  end

  def current_user_admin?
    current_user.groups.find_by_group_name("Administrators")
  end

  def current_user_moderator?
    current_user.groups.find_by_group_name("Administrators") ||
      current_user.groups.find_by_group_name("Moderators") || 
      current_user.groups.find_by_group_name("Security leaders") 
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

  def deny_access
    redirect_to sign_in_path, :notice => "Please sign in."
  end
end
