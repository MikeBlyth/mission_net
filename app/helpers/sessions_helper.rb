module SessionsHelper
  def current_user
    @current_user ||= (Member.find(session[:user_id]) if session[:user_id])
  end

  # What is the higest privilege level contained in a set of groups (e.g. the groups a user belongs to)?
  # This assumes the scheme were privilege levels are hard coded as boolean columns in the group
  # The priority level is determined by the order of the "return" statements -- check for administrator
  # first since it's the highest level, and limited last since it's the lowest (other than none)
  def highest_privilege(groups=[])
    admin = mod = memb = limited = nil
    groups.each do |g|
      admin ||= g.administrator
      mod ||= g.moderator
      memb ||= g.member
      limited ||= g.limited
    end
    return :administrator if admin
    return :moderator if mod
    return :member if memb
    return :limited if limited
    return nil
  end

  # Set of boolean methods to describe user's privilege level. Uses the same order of privileges
  # administrator > moderator > member > limited > none
  # in order to return "true" if the user belongs to the specified or higher privilege group
  # (e.g., "current_user_member?" is true even if the user is only in an administrator group,
  # because admin is higher than member)

  def current_user_admin?
#    current_user.groups.find_by_group_name("Administrators")
    highest_privilege(current_user.groups) == :administrator
  end

  def current_user_moderator?
    [:administrator, :moderator].include? highest_privilege(current_user.groups)
#    current_user.groups.find_by_group_name("Administrators") ||
#      current_user.groups.find_by_group_name("Moderators") || 
#      current_user.groups.find_by_group_name("Security leaders") 
  end

  def current_user_member?
    [:administrator, :moderator, :member].include? highest_privilege(current_user.groups)
  end

  def current_user_limited?
    [:administrator, :moderator, :member, :limited].include? highest_privilege(current_user.groups)
  end
  
  # Other Methods

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
