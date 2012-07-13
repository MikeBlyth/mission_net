module NotifierHelper

MISSING = '*** MISSING ***'
MISSING_CONTACT = '---None on file---'
  
  # Given response_time_limit in minutes, using current time 
  # generate phrase like 'immediately', by '2:43 pm', or
  # 'by 2:43 PM 24 Jun.' 
  def respond_by(response_time_limit, html=true)
    deadline = (Time.now + response_time_limit*60).in_time_zone(Joslink::Application.config.time_zone)
    max_minutes = response_time_limit  # just renaming for convenience
    formatted = case max_minutes
    when 0..59 then "<strong>immediately</strong>"
    when 60..360 then "<strong>by #{deadline.strftime("%l:%M %p")}</strong>"
    else "by #{deadline.strftime("%l:%M %p %-d %b")}"
    end
    formatted.gsub!(/<strong>|<\/strong>/,'') unless html
    return formatted.html_safe
  end
  
  def member_summary_footer
    "\n\n[#{SiteSetting.organization} Database #member_summary]"
  end

  def member_summary_content(member)
    s = summary_header + "\n"
    s << member_summary_core(member)
    s += member_summary_footer
    return s
  end
  
  def summary_header
    s  = <<"SUMMARYHEADER"
Your #{SiteSetting.organization} Database Information

Please take a minute to review the information we have for you on the #{SiteSetting.organization} 
database. We're trying to make sure everything is accurate. Contact information is
particularly important since in case of crisis or emergency we need to be able
to contact you. 

Confidentiality

Information marked with an asterisk "*" could appear in the #{SiteSetting.organization} directory, 
calendars, or other lists. You may request your email, phone numbers, and Skype 
name to be private if you wish. Other contact information may appear in the directory.
SUMMARYHEADER
    return s
  end
    
  def member_summary_core(m)
member_info = <<"MEMBERINFO"
*Name: #{m.name}
*Location in Nigeria: #{m.location}
Citizenship: #{m.country_name || MISSING}
Contact information
#{m.contact_summary_text(:prefix=>"  *") || MISSING_CONTACT}

MEMBERINFO
    return member_info
  end
  
end # module


