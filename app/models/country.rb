class Country < ActiveRecord::Base
  attr_accessible :code, :include_in_selection, :name, :nationality
end
# == Schema Information
#
# Table name: countries
#
#  id                   :integer         not null, primary key
#  code                 :string(255)
#  name                 :string(255)
#  nationality          :string(255)
#  include_in_selection :string(255)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#

