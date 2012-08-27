#require 'authentication_helper'

class LocationsController < ApplicationController

  load_and_authorize_resource
  
  active_scaffold :location do |config|
    config.columns  = [:code, :description, :city]
    config.columns[:city].actions_for_association_links = [:list]
    config.show.link = false
    config.update.link = false
    config.columns[:description].inplace_edit = true
    config.columns[:code].inplace_edit = true
    config.columns[:city].inplace_edit = true
    config.columns[:city].form_ui = :select
    config.create.columns = [:code, :description, :city]
  end
end

