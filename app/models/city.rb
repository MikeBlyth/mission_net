class City < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :name
  has_many :locations
end
