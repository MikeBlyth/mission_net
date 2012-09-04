module ModelHelper

#  def code_with_description
#    s = self.code.to_s + ' ' + self.description
#    return s
#  end

  # Validate that this record does not have any extant child records, so that we can delete this
  # record safely without orphaning anything. Uses reflect_on_all_associations to gather all the
  # has_many associations and check them. May or may not be worth using this rather than simply
  # putting customized validation into each model for its own associations.
  def check_for_linked_records
    valid = true
    myclass = self.class
    myassoc = myclass.reflect_on_all_associations(:has_many) # returns array of associations
    if !myassoc.empty?
      myassoc.each do |a|
        assoc_name = a.name   # This is a symbol like :member
        if self.send(assoc_name).first  # e.g., if a is :member, becomes record.member, returns array of matches
                                         # If not nil, there is at least one existing linked record
          errors.add(:base, 
            "#{self.send(assoc_name).count} #{assoc_name.to_s} record(s) with this #{myclass} still exist.")
#puts "**** #{self.send(assoc_name).count} #{assoc_name.to_s} record(s) with this #{myclass} still exist."
          valid = false
        end
      end
    end
    return valid # defaults to true, set to false in loop if any errors
  end

end
