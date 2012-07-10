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

class AppLog < ActiveRecord::Base
  # attr_accessible :title, :body
end
