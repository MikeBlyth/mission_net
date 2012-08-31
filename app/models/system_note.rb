# == Schema Information
#
# Table name: system_notes
#
#  id         :integer         not null, primary key
#  category   :string(255)
#  note       :string(255)
#  status     :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class SystemNote < ActiveRecord::Base
  attr_accessible :category, :note
end
