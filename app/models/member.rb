# == Schema Information
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
#  bloodtype_id            :integer
#  created_at              :datetime        not null
#  updated_at              :datetime        not null
#  phone_private           :boolean
#  email_private           :boolean
#  in_country              :boolean
#  comments                :string(255)
#  short_name              :string(255)
#  wife_id                 :integer
#  sex                     :string(255)
#


############## JOSLINK ###################

class Member < ActiveRecord::Base
  include NameHelper
  require 'sessions_helper'
  include SessionsHelper
  include ApplicationHelper
  
  extend ExportHelper

  attr_accessible :arrival_date, :departure_date, :email_1, :email_2, :name, :first_name, :last_name, :middle_name, 
      :short_name, :location_detail, :location_id, :phone_1, :phone_2, 
      :receive_email, :receive_sms, :emergency_contact_phone, :emergency_contact_email, :emergency_contact_name,
      :country_id, :blood_donor, :bloodtype_id, :bloodtype, :groups, :group_ids,
      :in_country, :comments, :phone_private, :email_private, :country, :location, :wife, :wife_id
  attr_accessor :role_cache_duration  
  has_and_belongs_to_many :groups
  has_one :husband, :class_name => 'Member', :foreign_key => :wife_id
  belongs_to :wife, :class_name => 'Member'
  has_many :sent_messages
  has_many :messages, :through => :sent_messages
  has_many :authorizations
  belongs_to :country
  belongs_to :location
  belongs_to :bloodtype
  validates_uniqueness_of :name
  validates_presence_of :name
  before_save :format_phone_numbers
  
  def initialize(*args)
    @role_cache_duration = 60 # seconds
    super
  end
  
# *************** Class methods *************

#  def self.authorized_for_create?
#    false # or some test for current user
#  end

  def self.auto_update_all_in_country_statuses
    do_updates = [1, '1', 'Yes', 'yes', true].include? SiteSetting.auto_update_in_country_status
    self.all.each {|m| m.auto_update_in_country_status(do_updates)}
  end
  
  def self.find_with_name(name, conditions="true")
#puts "Find_with_name #{name}"
    return [] if name.blank?
    filtered = self.where(conditions)
    result = filtered.where("first_name LIKE ? OR last_name LIKE ? OR name LIKE ?", name+"%", name+"%", name+"%")  
    if name =~ /(.*),\s*(.*)/
      last_name, first_name = $1, $2
    elsif name =~ /(.*)\s(.*)/
      last_name, first_name = $2, $1
    else
      last_name = first_name = nil
    end
    if last_name && first_name      
      result += filtered.where("last_name LIKE ? AND ((first_name LIKE ? OR short_name LIKE ?) )", 
          last_name+"%", first_name+"%", first_name+"%")
    end
    return result.uniq.compact
  end

  # Use a string like "Al Wright 0803-388-8888" to update Al Wright's data
  # Return {:member => <some member>, updates => <update attribute hash>}
  def self.parse_update_command(str)
    s = str.gsub(/<mailto.*>/,'')
    tokens = s.split
    names = []
    phones = []
    emails = []
    groups = []
    updates = {}
    tokens.each do |token|
      case 
        when phone = token.phone_std  # phone_std returns nil if not a valid phone number
          phones << phone
        when token =~ /\A[^@ ]+@[^@ ]+\.[^@ ]+\Z/  # Very broad email address validator
          emails << token
        else
          names << token if (phones + emails).empty?
      end
    end
    (0..1).each do |i|
      updates["phone_#{i+1}".to_sym] = phones[i] if phones[i]
      updates["email_#{i+1}".to_sym] = emails[i] if emails[i]
    end
    name_string = names.join(' ')
    member = Member.find_with_name(name_string) # may match none, one, or many members
    return add_member_params(name_string, updates) if member.empty?  # assume it's for adding a new member
#puts "**** member=#{member}, updates=#{updates}"
    return {:members => member, :updates => updates}
  end
  
  def self.add_member_params(name, updates)
    {:members => [], :updates => parse_namestring(name).merge(updates)}
  end

  def self.find_by_phone(phone_number)
    target_phone = (phone_number[0] == '+' ? phone_number[1..20] : phone_number)
    Member.where("phone_1 = ? OR phone_2 = ?",target_phone, target_phone).readonly(false).all
  end

  def self.find_by_email(email)
    Member.where("email_1 = ? OR email_2 = ?", email, email).readonly(false).all
  end

  # This is a stub that can be filled in later to limit outgoing messages to people who are still
  # in the country, on location, active, or whatever. Or we could simply define another column for 
  # members, since we don't plan to do travel-tracking in this version
  def self.those_in_country
    return self.where(:in_country => true)
  end

#******** INSTANCE METHODS **************

  def <=>(other)
    self.name <=> other.name
  end  


  # This stub helps bridge from the larger program that uses separate contact records. It would be best for clarity to change 
  # all "member.primary_contact." to "member" but this accomplishes the same thing.
  def primary_contact
    self
  end

  # Generate hash of contact info ready for display;
  # * join multiple phones and emails
  # * add "private" notice if needed
  # e.g. {'Phone' => '0803-385-4175, 0816-297-4144 (private)', 'Email' => 'me@lemon.com'}
  #      {'Phone' => '*private*', 'Email' => 'me@dog.org'}
  def contact_summary(params={})
    phones = smart_join([phone_1, phone_2].map {|p| p.phone_format if p}, ", ")
    emails = smart_join([email_1, email_2], ', ')
    override_private = params[:override_private]    
    return {'Phone' => filter_private(phones, phone_private, override_private),
            'Email' => filter_private(emails, email_private, override_private)
            }
  end

  def contact_summary_text(params={})
    prefix = params[:prefix] || ''
    separator = params[:separator] || "\n"
    include_blanks = params[:include_blanks]
    fields = ['Phone', 'Email']
    summary_hash = self.contact_summary
    summary = fields.map do |f|
      content = summary_hash[f]
      "#{f}: #{content}" if (!content.blank? || include_blanks)
    end
    return prefix + summary.compact.join("#{separator}#{prefix}")
  end
  
  def filter_private(field, marked_as_private, override_private)
    return field unless marked_as_private
    return '*private*' unless override_private
    return "#{field} (private)"
  end 
  
  def country_name
    Country.find(country_id).name if country_id
  end

  def primary_phone(options={:with_plus => false})
    phone = phone_1 || phone_2
    phone = phone[1..20] if phone && !options[:with_plus] && phone[0]=='+'
    return phone
  end

  # Use the Departure and Arrival dates to calculate whether person is in country.
  def calculate_in_country_status
    today = Date.today
    arr = arrival_date
    dep = departure_date
    original_status = [in_country, dep, arr]
    new_status = case
    when dep && arr && dep < arr   # dates mark period when person will be out of country
      case 
        when today > arr then [true, nil, arr] # person has already arrived
        when today >= dep then [false, dep, arr]  # person has departed and not arrived
        else original_status # not yet departed; in_country should be true, but we'll leave it alone
      end
    when dep && arr && dep >= arr  # dates mark period when person will be IN the country 
      case 
        when today > dep then [false, nil, nil] # person has already departed
        when today >= arr then [true, dep, arr]  # person has arrived and not departed
        else original_status # not yet arrived; in_country should be false, but we'll leave it alone
      end
    when dep && arr.nil?    # date when person will leave the country 
      today > dep ? [false, dep, nil] : original_status   
    when dep.nil? && arr    # date when person will arrive in the country 
      today >= arr ? [true, nil, arr] : original_status  
    else 
      original_status
    end      
logger.info "**** #{self.shorter_name}:\t#{original_status[0]}=>#{new_status[0]}\t#{original_status[1]}=>#{new_status[1]}\t#{original_status[2]}=>#{new_status[2]}" unless new_status == original_status
    AppLog.create(:code => 'Member.update', :description => 
      "**** #{self.shorter_name}:\t#{original_status[0]}=>#{new_status[0]}\t#{original_status[1]}=>#{new_status[1]}\t#{original_status[2]}=>#{new_status[2]}") unless new_status == original_status
    return new_status
  end

  def auto_update_in_country_status(do_updates)
    self.in_country, self.departure_date, self_arrival_date = calculate_in_country_status
    self.save if do_updates
  end

  def primary_email(options={})
    return email_1 || email_2
  end

  # ToDo: The whole area of privileges/roles needs to be reworked -- getting cumbersome
  # This is probably redundant and can just be replace with the direct calls
#  def has_role?(role)
#    case role
#      when :administrator then return administrator?(self)
#      when :moderator then return moderator?(self)
#      when :member then return member?(self)
#      when :limited then return limited?(self)
#    end
#    return nil
#  end

  # Use this member's groups to find the highest assigned role
  # ToDo: This duplicates sessions_helper's highest_role(groups) method ... refactor to remove that one.
  def recalc_highest_role
    admin = mod = memb = limited = nil
#puts "**** Member.recalc_highest_role self.groups=#{self.groups}"
    self.groups.each do |g|
      admin ||= g.administrator
      mod ||= g.moderator
      memb ||= g.member
      limited ||= g.limited
    end
    return :administrator if admin
    return :moderator if mod
    return :member if memb
    return :limited if limited
    return nil
  end
 
#  def role
#    userkey = "user:#{self.id}"
## puts "**** Member.role $redis.hget(userkey, :role)=#{$redis.hget(userkey, :role)}"
#    unless myrole = $redis.hget(userkey, :role)  # This is INTENTIONALLY an assignment, not a "==" comparison
#      myrole = recalc_highest_role
#      $redis.hset(userkey, :role, myrole) # Cache role so we don't have to check it a zillion times from the DB 
#      $redis.expire(userkey, @role_cache_duration)  # keep cached for 60 seconds 
##puts "**** caching role for @role_cache_duration=#{@role_cache_duration} sec"
#    end
##puts "**** Member.role: user=[#{self.id}] #{self}, role=#{myrole}" 
#    return myrole.nil? ? nil : myrole.downcase.to_sym      
#  end

  def role
    @role ||= recalc_highest_role
  end

  def roles_include?(queried_role)
    return nil if queried_role.nil?
    role_hierarchy = [:limited, :member, :moderator, :administrator]
    self_index = role_hierarchy.index(self.role)
    queried_index = role_hierarchy.index(queried_role)
    return self_index && queried_index && (self_index >= queried_index)
  end
  
  def add_authorization_provider(auth_hash)
    # Check if the provider already exists, so we don't add it twice
    unless authorizations.find_by_provider_and_uid(auth_hash["provider"], auth_hash["uid"])
      authorizations.create :provider => auth_hash["provider"], :uid => auth_hash["uid"]
    end
  end
  
  
  def format_phone_numbers
    self.phone_1, self.phone_2 = std_phone(phone_1), std_phone(phone_2)
  end

  def merge_group_ids(params=params, selectable=nil)
    if current_user.roles_include? :moderator
      selectable ||= Group.where("administrator = ? OR administrator IS ?", false, nil).to_id_set
    else
      selectable ||= Group.where("user_selectable").to_id_set
    end
    original_groups = self.groups.to_id_set
    unchangeable = original_groups - selectable
    updates = (params[:record][:groups] || []).to_set
    valid_updates = updates & selectable
    return (unchangeable + valid_updates).compact.to_a
  end


 end
