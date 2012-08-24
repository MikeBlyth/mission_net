module ApplicationHelper

  MaxReportedLocStaleness = 24 # 24 hours
  DefaultReportedLocDuration = 6 # 6 hours
  MaxSmsLength = 160 # characters
  
  def code_with_description
    s = self.code.to_s + ' ' + self.description
    return s
  end

  # Given an object (or nil) described by method description_method, return 
  # * nil_value if object is nil or its description is missing or is "unspecified"
  # * description_method otherwise
  # Example:
  #   given m = Member with status=>on_field_status, residence_location=>nil, country=>nil
  #     description_or_blank(m.residence_location) returns nil
  #     description_or_blank(m.residence_location, "Unknown") returns "Unknown"
  #     description_or_blank(m.status) returns "On field"
  #     description_or_blank(m.country, '?', :name) returns '?'
  def description_or_blank(object, nil_value='', description_method=:description)
    nil_value = nil if nil_value == :nil
    return nil_value unless object
    value = object.send description_method || 'unspecified'
    return value.downcase == 'unspecified' ? nil_value : value
  end

  # Return first non-blank line from string which may contain many lines.
  def first_nonblank_line(str)
    return nil if str.nil? || str.blank?
    str.lines.find {|line| !line.blank?}.chomp
  end

  # Tries sending 'key' to object as method, then as hash key (string and symbol)
  #   so a model, a hash, or other object can be accessed the same way
  def method_or_key(object, key)
    if object.respond_to? key 
      return object.send(key)
    elsif object.is_a? Hash
      return object[key] || object[key.to_s] || object[key.to_sym]
    else
      return nil
    end
  end

  # Compare a string date with the date in object.method 
  # Return true if the string represents the same date in any "to_s" format
  def same_date(object, new_date_string, method, format=:default)
    return new_date_string.empty? if (object.nil? || (object.send method).nil? )
#puts "**** new_date_string=#{new_date_string}"
#puts "****(object.send method).to_s(format) =#{(object.send method).to_s(format)}"
    existing_date = object.send method
    return true if new_date_string == (existing_date).to_s(format)
    # even if it didn't match default, check if it matches other formats
    Date::DATE_FORMATS.each {|f| return true if new_date_string ==  existing_date.to_s(f[0])}
    return false
  end

  def to_local_time(time, format=:date_time, time_zone=Joslink::Application.config.time_zone)
    time.in_time_zone(time_zone).to_s(format) if time.respond_to? :in_time_zone
  end  


    def opposite_sex(s)
      return :male if s == :female
      return :female if s == :male
      return nil unless s.respond_to? :downcase
      return 'F' if s.downcase[0] == 'm'
      return 'M' if s.downcase[0] == 'f'
    end	
    
    # Returns true unless x = false.
    # Same as x || x.nil?
    def default_true(x)
      return x != false
    end

    # Join the elements in array a with delimiter (default ", ")
    #   but first trim whitespace from elements and delete blank elements
    # Example
    # smart_join([' a ', '', nil, 3.5, "25\n"]) -> "a, 3.5, 25" 
    def smart_join(a, delim=', ')
      a.collect{|x| (x || '').to_s.strip}.delete_if{|x| x.blank?}.join(delim)
    end
  
    # String delimited by any combo of space, ";" or "," is downcased and split into an array
    # "cat dog,mouse;lion" => ["cat", "dog", "mouse", "lion"]
    def delimited_string_to_array(s)
      s.nil? ? [] : s.downcase.gsub(',', ' ').gsub(';', ' ').split(' ')
    end

    # Just add '_id' to a string or symbol
    def link_id(s)
      return s if s =~ /_id\z/  # no change if it already ends in _id
      val = s.to_s + "_id"
      val = val.to_sym if s.is_a? Symbol
      return val
    end  
    
    # Return the value of an association id, 
    # For example link_value(record, :status) is the same as record.status_id
    # Link can be either the name (:status) or id (:status_id)
    def link_value(record, link)
      return record.send(link_id(link))  # where link_id adds '_id' if not there
    end  

    # This is just for Nigerian phone numbers for now, to keep it really simple
    # It's highly localized -- probably best to make it optional!
    # takes an 11-digit phone number starting in 0, or +234 plus 10 digits, and formats it
    # ToDo: make this optional
    def format_phone(s,options={})
      return s unless s.respond_to? :phone_format
      return s.phone_format(options)
    end

#    # Standardize phone number string to "+2349999999" format
#    def phone_std(s,options={})
#      return s unless s.respond_to? :phone_std
#      return s.phone_format(options)
#    end

  # with incoming body like
  #   COMMAND_1 
  #   command_2 Parameters for this command 
  #   ...
  # make array like [ [command_1, ''], [command_2, 'Parameters for this command']]
  # where a command is the first word on each line
  def extract_commands(body)
    commands = body.lines.map do |line| 
      line =~ /\s*(\S+)\s*(.*)?/ 
      [($1 || '').downcase, ($2 || '').chomp]
    end  
 #puts "*** Commands = #{commands}"
    return commands
  end
  
  # Update a "record" with paramater hash "update_params". If there are errors, add "record" to
  # the list "error_recs". This will be used by the built-in error-message-creator
  def update_and_check(record, update_params, error_recs)
    return unless record   # ignore empty records
    unless record.update_attributes(update_params)
      error_recs << record
    end
  end

  # Use input from the combined form to update member w personnel_data, primary contact, health data
  # Creates primary contact (and personnel_data) if needed
  # Save any error-generating records in error_recs
  # Return the updated records since they'll be used to fill the forms if they need to be sent back
  #   to the user because of errors.
  def update_one_member(member, member_params, pers_params, contact_params, health_params, error_recs)
    update_and_check(member, member_params, error_recs)
    pers_rec = member.personnel_data || PersonnelData.new
    update_and_check(pers_rec, pers_params, error_recs)
#puts "**** pers_rec.attributes=#{pers_rec.attributes}"
    contact_rec = member.primary_contact || member.contacts.new
    update_and_check(contact_rec, contact_params, error_recs)
    health_rec = member.health_data
    update_and_check(health_rec, health_params, error_recs)
    return [member, pers_rec, contact_rec, health_rec]
  end   

  # Need to remove these from params being sent back (for user to fix errors) 
  #   so that they don't get stuck onto form URL parameters.
  # (Symptom of the problem is that a field can't be changed after an error, get "URL too Long" error)
  def remove_unneeded_keys(params)
      [:head, :head_pers, :head_contact,
        :wife, :wife_pers, :wife_contact,
        :record, :family, :member,
        :authenticity_token
      ].each {|key| params.delete key}
  end

#******* Anything below this point is not in the module itself *********
end  # ApplicationHelper module

require "#{Rails.root}/config/initializers/date_formats.rb"

# Add some methods to nil so we don't always have to make it a special case
class NilClass
  def strip
    nil
  end
end

class String
  def phone_format(options={})
    if Settings.formatting.format_phone_numbers && !self.blank? 
      delim_1 = options[:delim_1] || " "
      delim_2 = options[:delim_2] || " "
      squished = self.ljust(7).gsub(/[^\+0-9]/,'').gsub(/\A\+?234/,'0')
      if squished.length == 11 && squished[0]=='0'
        return squished.insert(7,delim_2).insert(4,delim_1)
      end
    end
    return self  # nothing to do
  end

  # Standardize phone number string to "+2349999999" format
  def phone_std(options={})
    return nil if self.blank?
      raw = self
    # Replace initial 0 with country code (configurable, but probably includes +) and remove punctuation and spaces
    return raw.gsub(/\A0/,Settings.contacts.local_country_code).gsub(/-|\.| /,'')
  end

#  def phone_bare(options={})
#    return nil if self.blank?
#    return self[0] == '+' ? self[1..99] : self
#  end
#  
  def with_plus
    self[0] == '+' ? self : '+' + self
  end
  
  def without_plus
    self[0] == '+' ? self[1..255] : self
  end
  
  def trunc(len=15)
    short = self[0..len-1]
    short += '...' if self > short
    return short
  end
end

# Array method to remove blanks and nil. Might be a bit inefficient for large arrays 
# since it clones the array first rather than building another from scratch
class Array
  def not_blank
    self.clone.keep_if {|a| !a.blank?} 
  end

  def not_blank!
    self.keep_if {|a| !a.blank?} 
  end
end

# Add to_ordinal method to Fixnums, so we get 1.to_ordinal is 1st and so on
class Fixnum
  def to_ordinal
    if (10...20)===self
      "#{self}th"
    else
      g = %w{ th st nd rd th th th th th th }
      a = self.to_s
      c=a[-1..-1].to_i
      a + g[c]
    end
  end

  # Add methods blank? and empty? and make them false for all Fixnum
  def blank?
    return false
  end

  def empty?
    return false
  end
end # class Fixnum 

module ActiveRecord  
  class Base  

    def update_record_without_timestamping  
      class << self  
        def record_timestamps; false; end  
      end  

      save!  

      class << self  
        def record_timestamps; super ; end  
      end  
    end  

  end  
end

