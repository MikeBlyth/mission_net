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

# == Schema Information
#
# Table name: people
#
#  id                      :integer         not null, primary key
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
      :country_id, :blood_donor, :blood_type_id

  belongs_to :country
  belongs_to :location
  belongs_to :blood_type
  validate   :unique_name
  validates_presence_of :last_name, :first_name
  
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
  
  
end

