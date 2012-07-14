class SessionsController < ApplicationController

  skip_before_filter :authorize, :only => [:new, :create, :update]

  def new
  end

# Unlike many applications, this one authorizes only users who are already members in the list. That is, we do not
# have a separate list of users who can access the application. Anyone who is listed in the database can access
# it, and no one not listed can access it. 
#
# The omniauth application uses an external authenticating service (e.g. Facebook) to verify the user's credentials,
# returning a lot of info (request.env['omniauth.auth']) including the name and email address. We use the email address
# to match the member in the database (Member).

def create
  auth_hash = request.env['omniauth.auth']
  user_email = auth_hash['info']['email']
  user = Member.find_by_email(user_email).first
  if user.nil?
    render :text => "Sorry, that login doesn't work. Please try another or contact the system administrator."
    return
  end
 
  # This section does two things
  # (1) For users already logged in, add this provider as a valid way to authenticate 
  #     (not sure yet how we get to that point!) (Not using this part now)
  # (2) For those not already logged in, (a) retrieve the authorization record (or create it) and
  #     (b) put the user (member) id into the session, effectively logging in the user.
  if session[:user_id]
    # Means our user is signed in. Add the authorization to the user
    Member.find(session[:user_id]).add_authorization_provider(auth_hash)
 
    render :text => "You can now login using #{auth_hash["provider"].capitalize} too!"
  else
    # Don't actually need this if we're just going to use the email to identify the user, right?
    # Log him in or sign him up
#   auth = Authorization.find_or_create(auth_hash, user.id)
 
    # Insert the user into the session
    session[:user_id] = user.id
#    render :text => "Welcome #{user.first_name}!"
puts "**** root_path=#{home_path}"
    redirect_to home_path
  end
end

  # This gets called by the auth provider (e.g. Facebook) when the signin with the provider didn't work
  def failure
    render :text => "Sorry, but you didn't allow access to our app!"
  end
  
  def destroy
    session[:user_id] = nil
    render :text => "You've logged out!"
  end
  
end
