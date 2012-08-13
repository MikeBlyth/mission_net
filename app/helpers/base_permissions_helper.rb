module BasePermissionsHelper

  # Model Methods
  def authorized_for_read?
    current_user.roles_include?(:member)
  end    
    
  def authorized_for_update?
    current_user.roles_include?(:moderator)
  end    
    
  def authorized_for_create?
    current_user.roles_include?(:moderator) 
  end    
    
  def authorized_for_delete?
    current_user.roles_include?(:moderator)
  end    

  # Controller method
  def list_authorized?
    current_user.roles_include?(:member)
  end

  def list_authorized2?
    current_user.roles_include?(:member)
  end


end
