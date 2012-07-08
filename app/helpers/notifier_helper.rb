module NotifierHelper

MISSING = '*** MISSING ***'
MISSING_CONTACT = '---None on file---'
  
  def travel_reminder_content(travel)
    member = travel.member
    t = travel # for quick alias
    s = travel_reminder_header + travel_reminder_data(travel) + travel_reminder_footer
    return s
  end

  # Given response_time_limit in minutes, using current time 
  # generate phrase like 'immediately', by '2:43 pm', or
  # 'by 2:43 PM 24 Jun.' 
  def respond_by(response_time_limit, html=true)
    deadline = (Time.now + response_time_limit*60).in_time_zone(SIM::Application.config.time_zone)
    max_minutes = response_time_limit  # just renaming for convenience
    formatted = case max_minutes
    when 0..59 then "<strong>immediately</strong>"
    when 60..360 then "<strong>by #{deadline.strftime("%l:%M %p")}</strong>"
    else "by #{deadline.strftime("%l:%M %p %-d %b")}"
    end
    formatted.gsub!(/<strong>|<\/strong>/,'') unless html
    return formatted.html_safe
  end
  
 
  def travel_reminder_data(travel)
    t = travel # for quick alias
    s = <<"TRAVELREMINDERDATA"
Date and time: 
  #{t.date.to_s.strip}
  #{t.arrival ? 'Arriving' : 'Departing'} at #{t.time ? t.time.strftime('%l:%M %P').strip : MISSING} on airline #{t.flight || MISSING}

Travelers: 
  #{t.total_passengers} total (#{t.travelers})

Baggage/boxes: 
  #{t.baggage ? t.baggage.to_s + ' pieces' : MISSING }   

Purpose (personal/ministry-related/term-passage): 
  #{t.purpose_category=='?' ? '? (Ministry, Personal, or Term passage)' : t.purpose_category}

Guesthouse: 
  #{t.guesthouse ? t.guesthouse : (t.own_arrangements ? ' -- your own arrangements -- ' : MISSING)}

In-country travel including to airport: 
  #{t.own_arrangements ? ' -- your own arrangements -- ' : 'mission driver'}

TRAVELREMINDERDATA
    if t.return_date
      s << "Return trip:\n  You are planning to return on #{t.return_date.to_s.strip}"
      s << " at #{t.return_time.strftime('%l:%M %P').strip}" if t.return_time
    end
    return s
  end
  
  def travel_reminder_header
    s = <<"TRAVELREMINDERHEADER"
Greetings SIMer!

According to the travel schedule, you will be traveling soon. Please
take a moment to review the information we have to make sure it is
correct. We would hate to miss you at the airport, or not have a big-
enough vehicle to carry your boxes! If there are any corrections,
please send them to #{Settings.email.travel}. Thanks!

Note: dates and times are for the flight, not for leaving or arriving
      at your home.

Your trip information:
TRAVELREMINDERHEADER
    return s
  end    

  def travel_reminder_footer
    "\n\n[#{Settings.site.org} Database #travel_reminder]"
  end

  def family_summary_footer
    "\n\n[#{Settings.site.org} Database #family_summary]"
  end

  def family_summary_content(family)
    s = summary_header + "\n"
    s << "FAMILY HEAD\n"
    s << member_summary_content(family.head)
    s << ("SPOUSE\n" + member_summary_content(family.head.spouse)) if family.married_couple?
    unless family.children.empty?
      s << "CHILDREN\n"
      family.children.each {|c| s << child_summary_content(c) }
    end
    missing = family_missing_info(family)
    unless missing.empty?
      s << "SUMMARY OF IMPORTANT MISSING DATA\n  "
      s << missing.join("\n  ")
    end
    s += family_summary_footer
    return s
  end
  
  def summary_header
    s  = <<"SUMMARYHEADER"
Your #{Settings.site.org} Database Information

Dear SIMers,

Please take a minute to review the information we have for you on the #{Settings.site.org} 
database. We're trying to make sure everything is accurate. Contact information is
particularly important since in case of crisis or emergency we need to be able
to contact you. 

If you are not an SIM member then you are receiving this because you're considered
to be under the SIM "umbrella" in some way. If that is incorrect, please let us know.

Confidentiality

Information marked with an asterisk "*" could appear in the #{Settings.site.org} directory, 
calendars, or other lists. You may request your email, phone numbers, and Skype 
name to be private if you wish. Other contact information may appear in the directory.
The remainder of the information here will not be available except through the SIM 
Nigeria administration.
SUMMARYHEADER
    return s
  end

  def child_summary_content(m)
    "*Name: #{m.first_name}\n*Birth date: #{m.birth_date || MISSING}\nCitizenship: #{m.country_name}\n\n"
  end  
    
  def field_term_content(m)
    f = m.most_recent_term || FieldTerm.new
    pending = m.pending_term || FieldTerm.new
    p = m.personnel_data
info = <<"FIELDINFO"
Current Term
  Start or projected start: #{f.start_date || MISSING}      
  End or projected end: #{f.end_date || MISSING}     
Next Term
  Projected start: #{pending.start_date || ''}
Date Active with #{Settings.site.parent_org}: #{p.date_active || MISSING}
Projected end of #{Settings.site.org} service: #{p.est_end_of_service || MISSING}
FIELDINFO
    return info
  end  
    
  def member_summary_content(m)
member_info = <<"MEMBERINFO"
*Name: #{m.name}
*Birth date: #{m.birth_date || MISSING } (#{Settings.site.org} listing will not include year)
*Location in Nigeria: #{m.residence_location}
*Workplace: #{m.work_location}
*Ministry: #{m.ministry}
*Status: #{m.status}
Citizenship: #{m.country_name || MISSING}
Ministry comment: #{m.ministry_comment}
Education level: #{m.personnel_data.education || MISSING}

Contact information
#{m.primary_contact(:no_substitution=>true) ? m.primary_contact.summary_text(:prefix=>"  *") : MISSING_CONTACT}

Field Service Summary
#{field_term_content(m)}
MEMBERINFO
    return member_info
  end
  
  def member_missing_info(m)
    h = m.health_data
    p = m.personnel_data
    f = m.most_recent_term || FieldTerm.new
    pending = m.pending_term || FieldTerm.new
    c = m.primary_contact(:no_substitution=>true) || Contact.new
    # Make an array of [parameter, label] pairs, where each element is data required
    # for this member. Then last step generates, via map statement, an array of labels
    # representing the data that is missing.
    if m.child
      required_data = [ [m.birth_date, 'birth date'] ]
    else
      # Required for all adults
      required_data = [ [m.birth_date, "birth date"], [m.country, "country/nationality"],
                        [c.phone_1, "primary phone"], [c.email_1, "primary email"] ]
      # Required for SIM members
      if m.org_member  # For SIM actual members (not umbrella)
          required_data << [p.date_active, "date active with #{Settings.site.parent_org}"] 
        # For those on field
        if m.status && m.status.on_field && f.end_date.blank?
          required_data << [nil, 'estimated end of current term']
        end
        # On home assignment      
        if m.status && m.status.code == 'home_assignment' && 
              (pending.start_date.blank?)  # on furlough but no start-of-next-term
          required_data << [nil, 'estimated start of next term'] # nil 'cause we already know it's missing
        end               
      end
    end
    # Create new array where each element is the label (r[1]) for a value (r[0]) that is missing
    # Delete nil values with 'compact', leaving only the missing-value labels.
    return required_data.map{|r| r[1] if r[0].blank?}.compact   
  end #method

  def family_missing_info(family)
    s = []
    [family.head, family.spouse, family.children].flatten.compact.each do |m|
      missing = member_missing_info(m)
      s << "#{m.short}: #{missing.join('; ')}" unless missing.empty?
    end
    if family.head.personnel_data.est_end_of_service.blank? &&
       family.head.org_member
      s << "Note: please estimate or guess when you plan to leave #{Settings.site.org}\nif it is within the next five years"
    end
    return s
  end 

end # module


