class SetupController < ActionController::Base

  protect_from_forgery
  before_filter :check_users  # Setup can only be used before there are any members
  skip_authorization_check

  def initialize
  end
  
  def initialize_save
    first_user = Member.create(:first_name => params[:first_name], :last_name => params[:last_name], 
      :name => "#{params[:first_name]} #{params[:last_name]}",
      :email_1 => params[:email_1], :email_2 => params[:email_2],
      :groups => [Group.find_by_group_name('Administrators')]
    )
    session[:user_id] = first_user.id
    redirect_to('/home') 
  end
  
private
  def check_users
    redirect_to(sign_in_path) if Member.any?
  end
end
