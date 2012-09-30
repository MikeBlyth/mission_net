module ApplicationHelper

  MaxReportedLocStaleness = 24 # 24 hours
  DefaultReportedLocDuration = 6 # 6 hours
  MaxSmsLength = 160 # characters
  
###### COLUMN HELPERS *********
  def updated_at_column(record, column)
    I18n.l record.updated_at, :format => :short
  end    

  def created_at_column(record, column)
    I18n.l record.created_at, :format => :short
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
    if object.respond_to?(description_method) 
      value = object.send(description_method)
    else
      value = nil_value
    end
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
    return Date.parse(new_date_string) == existing_date
  end

  def to_local_time(time, format=:date_time, time_zone=Joslink::Application.config.time_zone)
    time.in_time_zone(time_zone).to_s(format) if time.respond_to? :in_time_zone
  end  

  # Clean log file
  def clean_old_file_entries(model, options={})
    return false unless model.respond_to?(:find_in_batches) &&  # An ActiveRecord table
      options.any?   # something to delete
    date_limit_count = 100.years.ago
    date_limit_spec = options[:retention_days] ? Date.today - options[:retention_days].to_i : 100.years.ago
    if options[:max_to_keep]
      log_max = options[:max_to_keep].to_i
      if log_max > 0 && model.count > log_max
        date_limit_count = model.order('created_at DESC').offset(log_max-1).limit(1)[0].created_at
      end
    end
    date_limit = [date_limit_spec, date_limit_count].max # Use most restrictive of date or count
    model.where('created_at < ?', date_limit).delete_all
  end

  # It can happen that the index to the last item in the database gets lost, so that an
  # attempted assertion fails with a duplicate key value error. This method
  # resets the indices on all the tables listed in the method. It would be possible to 
  # do it for all the models, but that has other issues (what if a model hasn't been loaded
  # yet--it can't be detected?)
  def resync_pg_database_max_ids
    %w(app_logs bloodtypes cities countries groups locations members messages 
       sent_messages system_notes).each do |table|
      sql = "select setval('#{table}_id_seq', (select max(id) + 1 from #{table}));"
#      puts sql
      ActiveRecord::Base.connection.execute(sql)
    end
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
    def smart_join(a, delim=', ', final=nil)
      values = a.collect{|x| (x || '').to_s.strip}.delete_if{|x| x.blank?}
      if values.many? && final    # Need to put in the final "and" or whatever
        values[0..-2].join(delim) + " #{final} " + values.last
      else
        values.join(delim)
      end
    end
  
    # Same as split, but strips blanks space from each value 
    def smart_split(s, delim=',')
      s.split(delim).map {|x| x.strip}
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
    
    # This is just for Nigerian phone numbers for now, to keep it really simple
    # It's highly localized -- probably best to make it optional!
    # takes an 11-digit phone number starting in 0, or +234 plus 10 digits, and formats it
    # ToDo: make this optional
    def format_phone(s,options={})
      return s unless s.respond_to? :phone_format
      return s.phone_format(options)
    end

    def std_phone(s)
      return s unless s.respond_to? :phone_std
      return s.phone_std
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
  def extract_commands(body, command_delim=SiteSetting.email_command_delimiter)
    commands = body.lines.map do |line| 
      next unless command_delim.blank? || line.strip!.first == command_delim
      line =~ /\s*(\S+)\s*(.*)?/ 
      [($1 || '').downcase, ($2 || '').chomp]
    end  
 #puts "*** Commands = #{commands}"
    return commands
  end
  
  def change_locale_to(new_locale)
    url_for(params.merge(:locale => new_locale))
  end

  #******* METHODS TO DO WITH NAMES ************#
  #**** see also names_helper *****#
  def add_indexed_name(name_hash)
    name_hash[:name] = name_hash[:last_name] +
      (name_hash[:first_name] ? ", #{name_hash[:first_name]}" : '') +
      (name_hash[:middle_name] ? " #{name_hash[:middle_name]}" : '')
    return name_hash  
  end

  def parse_namestring(name)
    return {} if name.blank?
    names = name.split("\s").map {|n| n.gsub(/[_\+]/, ' ')}
    name_hash = {}
    case names.count
      when 1 
       name_hash[:last_name] = names[0]
      when 2 
       name_hash[:last_name] = names[1]
       name_hash[:first_name] = names[0]
      when 3..100
       name_hash[:last_name] = names[-1]
       name_hash[:first_name] = names[0]
       name_hash[:middle_name] = names[1]
    end
    add_indexed_name(name_hash)
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
      space_delim = options[:unbreakable] ? "\u00A0" : " "
      delim_1 = options[:delim_1] || space_delim
      delim_2 = options[:delim_2] || space_delim
      squished = self.ljust(7).gsub(/[^\+0-9]/,'').gsub(/\A\+?234/,'0')
      if squished.length == 11 && squished[0]=='0'
        return squished.insert(7,delim_2).insert(4,delim_1)
      end
    end
    return self  # nothing to do
  end

  # Standardize phone number string to "2349999999" format
  # * replace leading zero with country code
  # * strip leading + 
  # * remove -, space, and . characters (why not just remove all non-digits??)
  def phone_std(options={})
    return nil if self.blank?
    raw = self.strip
    return nil unless raw =~ /\A(\+?|\(\+?)[0-9\-\. \(\)]+\Z/ # make sure only allowed characters
    # Replace initial 0 with country code (configurable, but probably includes +) and remove punctuation and spaces
    return raw.sub(/\A0/,Settings.contacts.local_country_code).gsub(/[\+\(\)\-\. ]/, '')
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


