class CitiesController < ApplicationController
  load_and_authorize_resource

  active_scaffold :city do |config|
    config.show.link = false
    config.update.link = false
    config.create.columns = [:name, :latitude, :longitude, :state]

  end
end 
