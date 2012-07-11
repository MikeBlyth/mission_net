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
class Country < ActiveRecord::Base
  before_destroy :check_for_linked_records
  attr_accessible :code, :include_in_selection, :name, :nationality
  validates_presence_of :name, :nationality
  validates_uniqueness_of :code, :name
  has_many :members

  def to_label
    self.name
  end
  def to_s
    self.name
  end
  def description
    self.name
  end

  def self.choices
    return Country.find(:all, :order => :name, :conditions=> 'include_in_selection = TRUE')
  end

  def self.countryname(ccode)
    return Country.find(:first, :conditions=> "code = '#{ccode}'").name
  end
end
# == Schema Information
#
# Table name: countries
#
#  id                   :integer         not null, primary key
#  code                 :string(255)
#  name                 :string(255)
#  nationality          :string(255)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  include_in_selection :boolean
#

