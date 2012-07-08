class Group < ActiveRecord::Base
  attr_accessible :description, :name, :parent_group_id, :primary
end
