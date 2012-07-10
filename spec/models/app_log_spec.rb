# == Schema Information
#
# Table name: app_logs
#
#  id          :integer         not null, primary key
#  severity    :string(255)
#  code        :string(255)
#  description :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

require 'spec_helper'

describe AppLog do
  pending "add some examples to (or delete) #{__FILE__}"
end
