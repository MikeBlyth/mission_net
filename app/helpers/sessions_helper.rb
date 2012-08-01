module SessionsHelper
  def current_user
    @current_user ||= (Member.find(session[:user_id]) if session[:user_id])
  end

  def current_user_admin?
    current_user.groups.find_by_group_name("Administrators")
  end

  # This is set up to automatically make Administrators and Security leaders moderators as well. Might be
  #   better to do it by using subgroupings.
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

  def login_allowed(user_email)
    members_with_email = Member.find_by_email(user_email)
    members_group = Group.find_by_group_name('Members')
    sec_group = Group.find_by_group_name('Security leaders')
    mod_group = Group.find_by_group_name('Moderators')
    admin_group = Group.find_by_group_name('Administrators')
    # Have to go through each group in priority order so that we return the member with the highest privileges
    members_with_email.each {|m| return m if m.groups.include? admin_group}
    members_with_email.each {|m| return m if m.groups.include? mod_group}
    members_with_email.each {|m| return m if m.groups.include? sec_group}
    members_with_email.each {|m| return m if m.groups.include? members_group}
    return false
  end

  def deny_access
    redirect_to sign_in_path, :notice => "Please sign in."
  end
end
