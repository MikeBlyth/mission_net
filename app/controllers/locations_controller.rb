require 'authentication_helper'

class LocationsController < ApplicationController
  before_filter :authenticate #, :only => [:edit, :update]
  include AuthenticationHelper
  
  active_scaffold :location do |config|
    config.columns  = [:code, :description, :city]
    config.columns[:city].actions_for_association_links = [:list]
    config.show.link = false
    config.columns[:description].inplace_edit = true
  end
end

