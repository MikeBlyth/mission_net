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
    # ToDo -- fix this kludge or make it unnecessary
    return 'missing head' if (!head_id.nil? && Person.where('id = ?',head_id).count == 0)
    (head_id? && head) ? head.last_name_first : '?'
  end
end


