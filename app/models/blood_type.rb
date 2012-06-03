class BloodType < ActiveRecord::Base
  attr_accessible :abo, :full, :rh, :comment
end
# == Schema Information
#
# Table name: blood_types
#
#  id         :integer         not null, primary key
#  abo        :string(255)
#  rh         :string(255)
#  full       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  comment    :string(255)
#

