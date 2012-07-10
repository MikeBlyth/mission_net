#require 'authentication_helper'

class LocationsController < ApplicationController
#  before_filter :authenticate #, :only => [:edit, :update]
#  include AuthenticationHelper
  
  active_scaffold :location do |config|
    config.columns  = [:name, :state, :city, :lga, :gps_latitude, :gps_longitude]
    config.show.link = false
    config.columns[:name].inplace_edit = true
    config.columns[:state].inplace_edit = true
    config.columns[:city].inplace_edit = true
    config.columns[:lga].inplace_edit = true
    config.columns[:gps_latitude].inplace_edit = true
    config.columns[:gps_longitude].inplace_edit = true
  end
end

