# == Schema Information
#
# Table name: families
#
#  id         :integer         not null, primary key
#  head_id    :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#
class Family < ActiveRecord::Base
 # include NameHelper
  
  attr_accessible :head
  has_many :people
  belongs_to :head, :class_name => "Person"

  def name
    head_id? ? head.last_name_first : '?'
  end
end


