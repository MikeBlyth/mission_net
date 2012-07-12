# == Schema Information
# Schema version: 20120710110255
#
# Table name: members
#
#  id                      :integer         not null, primary key
#  last_name               :string(255)
#  first_name              :string(255)
#  middle_name             :string(255)
#  name                    :string(255)
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


############## JOSLINK ###################
class Member < ActiveRecord::Base
  include NameHelper
  extend ExportHelper

  attr_accessible :arrival_date, :departure_date, :email_1, :email_2, :first_name, :last_name, :location_detail, :location_id, :middle_name, :phone_1, :phone_2, 
      :receive_email, :receive_sms, :emergency_contact_phone, :emergency_contact_email, :emergency_contact_name,
      :country_id, :blood_donor, :bloodtype_id
  has_and_belongs_to_many :groups
  has_many :sent_messages
  has_many :messages, :through => :sent_messages
  belongs_to :country
  belongs_to :location
  belongs_to :bloodtype
  validates_uniqueness_of    :name
  validates_presence_of :last_name, :first_name
  
# *************** Class methods *************

  def self.authorized_for_create?
    false # or some test for current user
  end

  def self.find_with_name(name, conditions="true")
#puts "Find_with_name #{name}"
    return [] if name.blank?
    filtered = self.where(conditions)
    result = filtered.where("first_name LIKE ?", name+"%") + filtered.where("last_name LIKE ?", name+"%") + 
      filtered.where("name LIKE ?", name+"%") 
    if name =~ /(.*),\s*(.*)/
      last_name, first_name = $1, $2
    elsif name =~ /(.*)\s(.*)/
      last_name, first_name = $2, $1
    else
      last_name = first_name = nil
    end
    if last_name && first_name      
      result += filtered.where("last_name LIKE ? AND ((first_name LIKE ?) )", 
          last_name+"%", first_name+"%")
    end
    return result.uniq.compact
  end

  def country_name
    Country.find(country_id).name if country_id
  end

  def primary_phone(options={:with_plus => false})
    phone = phone_1 || phone_2
    phone = phone[1..20] if phone && !options[:with_plus] && phone[0]='+'
    return phone
  end

  # This is a stub that can be filled in later to limit outgoing messages to people who are still
  # in the country, on location, active, or whatever. Or we could simply define another column for 
  # members, since we don't plan to do travel-tracking in this version
  def self.those_in_country
    return self.all
  end

  def primary_email(options={})
    return email_1 || email_2
  end

 end
