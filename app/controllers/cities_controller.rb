class CitiesController < ApplicationController
  load_and_authorize_resource

  active_scaffold :city do |conf|
  end
end 
