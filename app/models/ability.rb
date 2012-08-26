class Ability
  include CanCan::Ability
  include SessionsHelper
    
  def initialize(user)
ActiveRecord::Base.logger.level = 0# Logger::WARN
#    user ||= User.new # guest user (not logged in)

    # IMPORTANT NOTE: 
    # Under the current design, it is important to list the LOWEST roles here first, and ADMINISTRATOR last.
    # That's because if the user has a given role, the lower role checks will also reply "true". For 
    # example, if she is an administrator, then limited?(user) will also be true. 
    
    if user.nil?
      cannot :manage, :all
      return
    end

#puts "**** Ability#initialize: user=#{user}, role=#{user.role}"

    case user.role
      when :administrator
        can :manage, :all
#puts "**** user #{user} is administrator"        
      when :moderator
#puts "***** USER IS MODERATOR ****"
        can :manage, :all
        cannot [:create, :update, :delete], SiteSetting
      when :member
#puts "***** USER IS MEMBER ****"
        cannot [:manage], :all
        can [:read, :index, :search, :show_search, :search_field], :all
        cannot :read, [SiteSetting, AppLog]
        can :create, Message
        can :update, Member, :id => user.id  # Allow user to edit own records
        can :update, Member, :id => user.wife.id if user.wife  # Allow user to edit own records
        can :update, Member, :id => user.husband.id if user.husband  # Allow user to edit own records
      when :limited
#puts "***** USER IS LIMITED ****"
        cannot :manage, :all
        can [:read, :update], Member, :id => user.id
      else
#puts "**** USER HAS NO ROLES ****"        
    end

  end  # initialize
end # class

