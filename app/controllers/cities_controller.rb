class CitiesController < ApplicationController
  load_and_authorize_resource

  active_scaffold :city do |conf|
  end

  def list_authorized2?
    current_user.roles_include?(:member)
  end
end 
