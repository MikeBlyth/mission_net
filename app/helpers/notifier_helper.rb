module NotifierHelper

  # Given response_time_limit in minutes, using current time 
  # generate phrase like 'immediately', by '2:43 pm', or
  # 'by 2:43 PM 24 Jun.' 
  def respond_by(response_time_limit, html=true)
    deadline = (Time.now + response_time_limit*60).in_time_zone(Joslink::Application.config.time_zone)
    max_minutes = response_time_limit  # just renaming for convenience
    formatted = case max_minutes
    when 0..59 then "<strong>#{I18n.t(:immediately)}</strong>"
    when 60..360 then "<strong>#{I18n.t(:by_deadline, :deadline => deadline.strftime("%l:%M %p"))}</strong>"
    else "by #{I18n.t(:by_deadline, :deadline => deadline.strftime("%l:%M %p %-d %b"))}"
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
    I18n.t(:summary_header, :organization => SiteSetting.organization)
  end
    
  def member_summary_core(m)
    I18n.t(:member_summary_core, :name => m.name, :location => m.location,
       :passport_country => m.country_name || I18n.t(:MISSING), 
       :contact_summary => m.contact_summary_text(:prefix=>"  *") || I18n.t(:MISSING_CONTACT))

  end
  
end # module


