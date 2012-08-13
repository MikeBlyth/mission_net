include BasePermissionsHelper
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
  attr_accessible :severity, :code, :description
  before_save :control_description_length
  def self.tail(lines=10)
    reply = ''
    first_line = self.count > lines ? self.count-lines : 0
    self.order('id ASC').offset(first_line).each do |line|
      reply << "#{line.id} #{line.created_at} #{line.code} #{line.description}\n"
    end
    reply
  end

  def control_description_length
    self.description = self.description[0..254]
  end
end
