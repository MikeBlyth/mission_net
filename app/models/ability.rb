class Ability
  include CanCan::Ability
  include SessionsHelper
    
  def initialize(user)
#    user ||= User.new # guest user (not logged in)

    # IMPORTANT NOTE: 
    # Under the current design, it is important to list the LOWEST roles here first, and ADMINISTRATOR last.
    # That's because if the user has a given role, the lower role checks will also reply "true". For 
    # example, if she is an administrator, then limited?(user) will also be true. 
    
    if user.nil?
      cannot :manage, :all
      return
    end

    case 
      when administrator?(user)
        can :manage, :all
      when moderator?(user)
        can :manage, :all
        cannot [:create, :update, :delete], SiteSetting
      when member?(user)
        can :read, :all
        cannot :read, [SiteSetting, AppLog]
        can :create, Message
        can :update, Member, :id => user.id  # Allow user to edit own records
      when limited?(user)
        cannot :manage, :all
        can [:read, :update], Member, :id => user.id
    end

#    if user.nil?
#      cannot :manage, :all
#      return
#    end

#    if limited?(user)
#      cannot :manage, :all
#      can [:read, :update], Member, :id => user.id
#    end
#    
#    if member?(user)
#      can :read, :all
#      cannot :read, [SiteSetting, AppLog]
#      can :create, Message
#      can :update, Member, :id => user.id  # Allow user to edit own records
#    end

#    if moderator?(user)
#      can :manage, :all
#      cannot [:create, :update, :delete], SiteSetting
#    end
#    
#    if administrator?(user)
#      can :manage, :all
#    end

  end  # initialize
end # class

