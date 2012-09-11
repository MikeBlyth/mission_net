# For generating different kinds of reports output to PDF
# Perhaps should be refactored so that each report is inside its own main model's controller?
class ReportsController < ApplicationController
  include ApplicationHelper

#  load_and_authorize_resource

skip_authorization_check  # TEMPORARY -- what kind of control is actually needed if any?

  def index
    # this just displays a view that lets the user select from reports
  end

  # Main directory, printable report
  def directory
    # Who to include in the report ... options not implemented yet
    # include_home_assignment = params[:include_home_assignment]
    # include_active = params[:include_active]
#puts "ReportsController#whereis report, params=#{params}"
# TEMPORARY -- what kind of control is actually needed if any?
unless current_user.roles_include?(:moderator)
  flash[:notices] = I18n.t(:only_moderators_can, :action => 'generate reports')
  redirect_to home_path
  return
end
    to_groups = params[:record][:to_groups] if params[:record]
    include_groups = to_groups || :all  # Show everyone by default, particular groups if specified
    # Get "families", i.e. members who don't have husbands
    @families = Group.members_in_multiple_groups(include_groups).keep_if {|m| m.husband.nil?}
    @families = @families.sort
    @title = I18n.t SiteSettings.directory_title
    respond_to do |format|
      format.html do 
        if params[:by] == 'location'
          render :template=>'reports/directory_by_location' 
        else
          render :template=>'reports/directory' 
        end
      end
      format.pdf do
        output = DirectoryDoc.new(:page_size=>Settings.reports.page_size).
             to_pdf(@families, @visitors, params)
        if params[:mail_to] then
#puts "Mailing report, params=#{params}"
          Notifier.send_report(params[:mail_to], @title, output).deliver
          redirect_to reports_path
        else
          send_data output, :filename => "directory.pdf", 
                            :type => "application/pdf"
        end
      end
    end
  end


######## FROM OTHER PROJECT FOR SCAVENGING AS DESIRED ##################

#  def contact_updates
#    @contacts = Contact.recently_updated.sort
#  end

#  def send_contact_updates
#    @title = 'Send contact updates'
#    @contacts = Contact.recently_updated.sort
#    recipients = SiteSetting.contact_update_recipients
#    message = Notifier.contact_updates(recipients, @contacts)
#    message.deliver
#puts "#{message}"
#    flash[:notice] = "Sent contact updates."
#    AppLog.create(:severity=>'info', :code=>'Notice.contact_updates', 
#      :description => "#{@contacts.length} updated contacts, sent to #{recipients}")
#    redirect_to reports_path
#  end
# 
#   # Blood Type Reports
#   def bloodtypes
#     selected = Member.select("family_id, last_name, first_name, middle_name, status_id, id, child")
##selected.each {|x| puts ">> #{x.first_name}, #{x.status.description}, #{x.on_field}, #{x.health_data.bloodtype_id}, #{x.health_data.bloodtype}" }
#     # Delete members we don't want on the report
#     selected = selected.delete_if{|x| 
#                                    !x.on_field || 
#                                    x.health_data.nil? || 
#                                    x.child || 
#                                    x.health_data.bloodtype.nil? || 
#                                    x.health_data.bloodtype_id == UNSPECIFIED
#                                    } 

#     respond_to do |format|
#       format.pdf do
#         output = BloodtypeReport.new(:page_size=>Settings.reports.page_size).
#              to_pdf(selected,"Includes only those currently on the field")
#         send_data output, :filename => "bloodtypes.pdf", 
#                          :type => "application/pdf"
#       end
#     end
#   end

#  # Contact reports
#   def phone_email
#    selected = Member.where(conditions_for_collection).
#                      where("child is false").
#            select("family_id, child, last_name, first_name, middle_name, short_name, id")
#    filter = (session[:filter] || "").gsub('_', ' ')
#    left_head = filter.blank? ? '' : "with status = #{filter}" 

#    respond_to do |format|
#      format.pdf do
#        output = PhoneEmailReport.new(:page_size=>Settings.reports.page_size).
#              to_pdf(selected,:left_head=>left_head)
#        send_data output, :filename => "phonelist.pdf", 
#                          :type => "application/pdf"
#      end
#    end
#  end

  
#  # Return starting date for calendar. If the date is not specified in params,
#  #    use the first of the next month.
#  def date_for_calendar
#    if params[:date]
#      date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, 1)
#    else
#      next_m = Date::today().next_month
#      date = Date.new(next_m.year, next_m.month, 1)
#    end
##puts "date_for_calendar = #{date}"
#    return date
#  end

#  # Set up a new calendar object using parameters supplied in params, or defaults
#  def calendar_setup
#    date = date_for_calendar
#    page_size = params[:page_size] || Settings.reports.page_size
#    page_layout = params[:page_layout] || :landscape
#    box = params[:box] || false
#    title = params[:title] || "#{Date::MONTHNAMES[date.month]} #{date.year.to_s}"
##    title << " [filter = #{session[:filter]}]"
#    return CalendarMonthPdf.new(:title=>title, :date=>date, :page_size=>page_size, :page_layout=>page_layout, :box=>box)
#  end

#  def calendar
#    # Set up the calendar form for right month (page size, titles, etc.)
##puts "Calendar, params=#{params}"
#    calendar = calendar_setup
#       
#    birthday_data = params[:birthdays] ? birthday_calendar_data({:month=>date_for_calendar.month}) : []
#    travel_data = params[:travel] ? travel_calendar_data({:date=>date_for_calendar}) : []
#    events_data = params[:events] ? calendar_events_data({:date=>date_for_calendar}) : []
#    # Merge the different arrays of data--birthdays, travel, anything else
#    merged = merge_calendar_data([travel_data, birthday_data, events_data])

#    # Actually print the strings

#    respond_to do |format|
#      format.pdf do
#        calendar.put_data_into_days(merged)
#        send_data calendar.render, :filename => "calendar.pdf", 
#                          :type => "application/pdf"
#      end
#    end
#  end
 

private

#  # Generate data structure for birthdays to insert into calendar
#  def birthday_calendar_data(params={})
#    prefix = Settings.reports.birthday_calendar.birthday_prefix # Something like "BD: " or icon of a cake, to precede each name
#    month = params[:month] || 1
#    selected = Member.where(conditions_for_collection).select("family_id, last_name, first_name, middle_name, birth_date, short_name, status_id")

#    # Make a hash like { 1 => {:text=>"BD: John Doe\nBD: Mary Smith"}, 8 => {:text=>"BD: Adam Smith\n"}}
#    # Using the inner hash leaves us room to add options/parameters in the future
#    data = {} 
#    selected.each do |m|
#      if m.birth_date && (m.birth_date.month == month ) # Select people who were born in this month
#        data[m.birth_date.day] ||= {:text=>''}
#        data[m.birth_date.day][:text] << prefix + m.full_name_short + "\n" 
#      end
#    end
#    return data
#  end # birthday_calendar_data

#  # Note: Perhaps most of this should be moved into the Travel model 
#  # Generate data structure for travel to insert into calendar
#  def travel_calendar_data(params={})
#    prefixes = {true=>Settings.reports.travel_calendar.arrival_prefix, false=>Settings.reports.travel_calendar.departure_prefix}
#    starting_date = params[:date]
#    selected = Travel.where("date >= ? and date < ?", starting_date, starting_date.next_month).order("date ASC")
#    # Make a hash like { 1 => {:text=>"AR: John Doe\nDP: Mary Smith"}, 8 => {:text=>"AR: Adam Smith\n"}}
#    data = {} 
#    selected.each do |trip|
#      data[trip.date.day] ||= {:text=>''}
#      data[trip.date.day][:text] << prefixes[trip.arrival?] + trip.traveler_name.trunc(18) + "\n" 
#    end
#    return data
#  end # travel_calendar_data

#  # Note: Perhaps most of this should be moved into the CalendarEvent model 
#  # Generate data structure for travel to insert into calendar
#  def calendar_events_data(params={})
#    starting_date = params[:date]
#    selected = CalendarEvent.where("date > ? and date < ?", starting_date, starting_date.next_month).order("date ASC")
#    # Make a hash like { 1 => {:text=>"AR: John Doe\nDP: Mary Smith"}, 8 => {:text=>"AR: Adam Smith\n"}}
#    data = {} 
#    selected.each do |e|
#      data[e.date.day] ||= {:text=>''}
#      event_time = e.date.strftime("%l:%M %p").strip
#      data[e.date.day][:text] << e.event
#      data[e.date.day][:text] << " " << event_time if event_time != "12:00 AM"
#      data[e.date.day][:text] << "\n"
#    end
#    return data
#  end # travel_calendar_data

#  def merge_calendar_data(data_hashes)
#    merged = {}
#    data_hashes.each do |data_hash|
#      data_hash.each do |date, content|
#        merged[date] ||= {:text=>''}
#        content.each do |key, value|  # Remember content is a hash with text plus options
#          if key == :text
#            merged[date][:text] << value
#          else
#            merged[date][key] ||= value  # Idea here is to set the parameter only once, first come first saved
#          end    
#        end # of each element in content for this date in this data_hash
#      end  # of data_hash.each, handling a single list such as the travel data  
#    end  # of data_hashes.each, handling the whole set of data to be merged
#    return merged
#  end # of merge_calendar_data
#  

end
