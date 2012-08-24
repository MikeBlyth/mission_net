require 'reports_helper'
include MembersHelper


class DirectoryDoc < Prawn::Document
  include ReportsHelper
  include ApplicationHelper
    
  # Return the data to be inserted into table from member
  def family_data_line(member, options = {})
    formatted = family_data_formatted(member)
    location_string = options[:location].nil? ? '' : description_or_blank(member.location)
    name_column = formatted[:couple_w_status] + location_string
    return [ name_column, smart_join(formatted[:emails], "\n"), smart_join(formatted[:phones], "\n") ]
  end

  def to_pdf(families, visitors=[], options = {})
    options[:location] ||= 'short'
    location_col = options[:location_column] # make separate column for locations? 

    # Part 1 -- Sorted by location
    page_header(:title=>SiteSetting.directory_title)#, :left => comments)
    families_by_location = families.sort do |x,y| 
      (description_or_blank(x.location,'Zz') + x[:name]) <=> 
      (description_or_blank(y.location,'Zz') +y[:name])
    end
    if location_col
      table_data = [['Location','Name', 'Email', 'Phone']]
    else
      table_data = [['Name', 'Email', 'Phone']]
    end
      
    location = ''
    families_by_location.each do |f|
      # Check for new residence location so we can group
      this_location = description_or_blank(f.location)
      if this_location != location   # same as previous location?
        location = this_location  # no, start new grouping
        column_location = location  # for display in separate column_location
        heading_location = location.blank? ? I18n.t(:unspecified_location) : location
        unless location_col  # Give new location its own row if it does not have its own column
          table_data << ["<b>#{heading_location}</b>", '', ''] # Need enough columns to fill the row, or borders won't be right
        end  
      else
        column_location = ''  # not a new location, so don't show it in the location column (but what about top of page!?)
      end
      if location_col
        table_data << [column_location] + family_data_line(f, options.merge({:location=>'modifiers'}))
          # (we don't want locations displayed with each family in this part since they're displayed separately)
      else
        table_data << family_data_line(f, options.merge({:location=>nil}))
      end
    end

    bounding_box [0, cursor-20], :width => bounds.right-bounds.left, :height=> (cursor-20)-bounds.bottom-20 do

      table(table_data, :header => true, 
                      :row_colors => ["F0F0F0", "FFFFCC"],
                      :cell_style => { :size => 10, :inline_format => true},
                      :column_widths => {1=> 200, 2 => 170}) do 
        row(0).style :background_color => 'CCCC00', :font => 'Times-Roman'
      end
      
      # Part 2 -- Sorted by family
      table_data = [['<i>Name</i>', 'Email', 'Phone']]
      families.each do |f|
        table_data << family_data_line(f, {:location => nil}.merge(options))
      end      
      start_new_page
      table(table_data, :header => true, 
                      :row_colors => ["F0F0F0", "FFFFCC"],
                      :cell_style => { :size => 10, :inline_format => true},
                      :column_widths => {1=> 200, 2 => 170}) do 
        row(0).style :background_color => 'CCCC00', :font => 'Times-Roman'
        column(1).style :width=>150
      end

    end # bounding_box


    render
  end
end
