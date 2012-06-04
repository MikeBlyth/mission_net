# == Schema Information
#
# Table name: locations
#
#  id            :integer         not null, primary key
#  name          :string(255)
#  state         :string(255)
#  city          :string(255)
#  lga           :string(255)
#  gps_latitude  :float
#  gps_longitude :float
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#
class Location < ActiveRecord::Base
  attr_accessible :city, :gps_latitude, :gps_longitude, :lga, :name, :state
  
  def to_s
    self.name
  end
end

