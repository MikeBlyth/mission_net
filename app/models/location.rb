include BasePermissionsHelper

# == Schema Information
#
# Table name: locations
#
#  id          :integer         not null, primary key
#  description :string(255)
#  city_id     :integer         default(999999)
#  created_at  :datetime
#  updated_at  :datetime
#  code        :integer
#

class Location < ActiveRecord::Base
  attr_accessible :city, :gps_latitude, :gps_longitude, :lga, :name, :state, :city_id, :code, :description
  belongs_to :city
  def to_s
    self.description
  end
end

