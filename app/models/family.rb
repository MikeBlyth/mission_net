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
  # attr_accessible :title, :body
  has_many :people
  belongs_to :head, :class_name => "Person"

  def name
    head_id? ? head.last_name : '?'
  end
end


