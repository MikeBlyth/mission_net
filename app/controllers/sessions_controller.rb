class SessionsController < ApplicationController

  skip_before_filter :authorize, :only => [:new, :create, :update]
#c#  skip_authorization_check
  
  def new
    redirect_to(initialize_path) if Member.count == 0
  end

# This app authorizes only users who are already members in the list. That is, we do not
# have a separate list of users who can access the application. Anyone who is listed in the database can access
# it, and no one not listed can access it. 
#
# The omniauth application uses an external authenticating service (e.g. Facebook) to verify the user's credentials,
# returning a lot of info (request.env['omniauth.auth']) including the name and email address. We use the email address
# to match the member in the database (Member).

def get_authorization
  auth_hash = request.env['omniauth.auth']
puts "**** (1) auth_hash=#{auth_hash}"
  return auth_hash
end

def create
  #********* HACK FOR TESTING ************************#
  #******** SHOULD NOT BE IN PRODUCTION MODE UNLESS HARDENED
  if (Rails.env == 'test') && (Member.count < 10)       # Trying to protect against running it with real data
    member=Member.find_by_name('test')
    user_email = member ? member.email_1 : 'bademailaddress'
  else
    # This is the only part that should remain for production!
    auth_hash = get_authorization
puts "**** (2) auth_hash=#{auth_hash}"
    user_email = auth_hash['info']['email']
  end
  #*****************************************************

  user = login_allowed(user_email)
  unless user
    flash[:info] = "Sorry, that login is not authorized to use this application. Please try another or contact the system administrator."
    redirect_to sign_in_path
    return
  end
 
  # This section does two things
  # (1) For users already logged in, add this provider as a valid way to authenticate 
  #     (not sure yet how we get to that point!) (Not using this part now)
  # (2) For those not already logged in, (a) retrieve the authorization record (or create it) and
  #     (b) put the user (member) id into the session, effectively logging in the user.
#puts "**** session[:user_id]=#{session[:user_id]}"
  if session[:user_id]
    # Means our user is signed in. Add the authorization to the user
    Member.find(session[:user_id]).add_authorization_provider(auth_hash)
  else
    # Insert the user into the session
    session[:user_id] = user.id
# puts "**** Successfully signed in"
  end
  redirect_to home_path
end

  # Safe landing page for authorization issues
  def safe_page
  end

  # This gets called by the auth provider (e.g. Facebook) when the signin with the provider didn't work
  def failure
    render :text => "Sorry, but that didn't work!"
  end
  
  def destroy
#puts "**** Session Destroyed ***"
    session[:user_id] = nil
    redirect_to sign_in_path
  end
  
end
