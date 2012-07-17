class Location < ActiveRecord::Base
  attr_accessible :city, :gps_latitude, :gps_longitude, :lga, :name, :state, :city_id, :code, :description
  belongs_to :city
  def to_s
    self.description
  end
end

