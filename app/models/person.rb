# == Schema Information
#
# Table name: people
#
#  id                      :integer         not null, primary key
#  family_id               :integer
#  last_name               :string(255)
#  first_name              :string(255)
#  middle_name             :string(255)
#  country_id              :integer
#  emergency_contact_phone :string(255)
#  emergency_contact_email :string(255)
#  emergency_contact_name  :string(255)
#  phone_1                 :string(255)
#  phone_2                 :string(255)
#  email_1                 :string(255)
#  email_2                 :string(255)
#  location_id             :integer
#  location_detail         :string(255)
#  arrival_date            :date
#  departure_date          :date
#  receive_sms             :boolean
#  receive_email           :boolean
#  blood_donor             :boolean
#  blood_type_id           :integer
#  created_at              :datetime        not null
#  updated_at              :datetime        not null
#
class Person < ActiveRecord::Base
  include NameHelper
  attr_accessible :arrival_date, :departure_date, :email_1, :email_2, :first_name, :last_name, :location_detail, :location_id, :middle_name, :phone_1, :phone_2, 
      :receive_email, :receive_sms, :emergency_contact_phone, :emergency_contact_email, :emergency_contact_name,
      :country_id, :blood_donor, :blood_type_id, :family_id

  belongs_to :country
  belongs_to :location
  belongs_to :blood_type
  belongs_to :family
  validate   :unique_name
  validates_presence_of :last_name, :first_name
  after_save :create_family_if_needed
  before_destroy :check_if_family_head
  
  # If a person does not belong to a family then create one
  def create_family_if_needed
    if family_id.nil?
      update_attributes(:family_id => Family.create(:head=>self).id)
    end
  end
  
private
  def unique_name
    if self.new_record?
      existing = Person.where("last_name = ? AND first_name = ? AND middle_name = ?", last_name, first_name, middle_name)
    else
      existing = Person.where("last_name = ? AND first_name = ? AND middle_name = ? AND NOT (id = ?)", last_name, first_name, middle_name, id)
    end
    unless existing.count == 0
      self.errors.add(:name, "already exists in database. Use existing person or modify this name.")
    end
  end
  
  def check_if_family_head
 puts "**** self.id=#{self.id}, family.head = #{family.head_id}"
    if self.family.head_id == self.id
      self.errors.add(:delete, "Can't delete head of family.")
      return false
    else
      true  
    end
  end
  
  
  
end

