module NameHelper
  
# EXAMPLES OF NAME FORMS 
# to_label:         Blyth, Michael
# indexed_name:     Blyth, Michael (Mike) J.
# full_name:        Michael John Blyth
# full_name_short:  Mike Blyth
# full_name_with_short_name: Michael John Blyth (Mike)
# shorter_name        M Blyth
# last_name_first:  Blyth, Michael John    (default)
#  :initial=>true   Blyth, Michael J.
#  :short=>true     Blyth, Mike John
#  :short_paren=>true Blyth, Michael (Mike) John 
#  :middle=>false   Blyth, Michael  

  # Before validation, create the name column if it is empty
  def set_indexed_name_if_empty
    if self.name.blank?
      self.name = indexed_name
    end
  end    

  def to_label
    last_name_first(:middle=>false)
  end
  
  def to_s
    last_name_first
  end

  # Indexed_name is the full name stored in the table. It is formed automatically on record
  # creation, re-formed if blank on updates. It must be unique. Stored in :name field of members table 
  def indexed_name
    last_name_first(:initial=>true, :paren_short => true)
  end
  
  def short
    short_name.blank? ? first_name : short_name
  end

  def full_name
    s = self.first_name
    s = s + ' ' + self.middle_name unless self.middle_name.blank?
    s = s + ' ' + self.last_name
    return s
  end

  def shorter_name
    "#{short[0]} #{last_name}"
  end

  def full_name_short
    if short_name.blank?
      s = first_name + " " + last_name
    else
      s = short_name + " " + last_name
    end
  end

  def middle_initial
    return nil if middle_name.blank?
    return middle_name[0]+'.'
  end

  def full_name_with_short_name
    s = self.full_name
    s = s + ' (' + self.short_name + ')' unless (self.short_name.blank? ) || self.short_name.eql?(self.first_name)
    return s
  end

  # First (or short) & middle names + last name only if different from family.last_name
  def name_optional_last
    n = short
    n << " #{middle_initial}" if middle_initial
    n << " #{last_name}" if !family || (last_name != family.last_name)
    return n
  end
    
  # Full name with last name first: Johnson, Alan Mark
  # Options
  # * :short => _boolean_ default false; use the short form of first name (e.g. "Al")
  # * :paren_short => boolean default false; append short name, if any, in "( )" 
  # * :initial => _boolean_ default false; use the initial instead of whole _middle_ name
  # * :middle => _boolean_ default true; include the middle name (or initial)
  def last_name_first(options={})
    return (last_name || '') + (first_name || '') if last_name.nil? || first_name.nil?
    options[:short] = false if options[:paren_short] # paren_short overrides the short option
    if options[:short] && !short_name.blank?   # use the short form of first name if it's defined
      first = short_name
    else
      first = first_name # || '*Missing First Name*'
    end
    if options[:initial] && !middle_name.blank?   # use middle initial rather than whole middle name?
      middle = middle_initial
    else
      middle = middle_name || ''
    end
    if (options[:paren_short]) && !short_name.blank? && short_name != first
      first = first + " (#{short_name})"
    end
    s = (last_name) + ', ' + first 
    s << (' ' + middle) unless options[:middle] == false || middle.empty?
    return s || ''
  end
  
end
