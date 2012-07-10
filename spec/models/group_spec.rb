require 'spec_helper'

describe Group do
  pending "add some examples to (or delete) #{__FILE__}"
end
# == Schema Information
#
# Table name: groups
#
#  id              :integer         not null, primary key
#  group_name      :string(255)
#  parent_group_id :integer
#  abbrev          :string(255)
#  primary         :boolean
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

