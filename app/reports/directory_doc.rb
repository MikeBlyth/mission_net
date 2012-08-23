require 'reports_helper'

class DirectoryDoc < Prawn::Document
  include ReportsHelper
  include ApplicationHelper
    
  # Return the data to be inserted into table from family f
  def family_data_line(f, options = {})
    formatted = family_data_formatted(f)
    location_string = case options[:location]
      when 'long' then  "\n<i>" +  f.current_location + "</i>"
      when 'short' then " (#{f.residence_location})"
      when 'modifiers' then "\n<i>" +  f.current_location(:with_residence=>false, :with_work=>false) + "</i>"
      else              ''  # when nil, don't include location at all
    end
    name_column = formatted[:couple] + 
                  (f.status.code == 'field' ? '' : " (#{f.status.description})") +
                  (formatted[:children].blank? ? '' : "\n\u00a0\u00a0<i>#{formatted[:children]}</i>" ) +
                  location_string
    return [ name_column, smart_join(formatted[:emails], "\n"), smart_join(formatted[:phones], "\n") ]
  end

  def to_pdf(families, visitors=[], options = {})
    options[:location] ||= 'short'
    location_col = default_true(options[:location_column]) # make separate column for locations? Default=true

    # Part 1 -- Sorted by location
    page_header(:title=>"Where Is Everyone?")#, :left => comments)
    families_by_location = families.sort do |x,y| 
      (description_or_blank(x.residence_location,'') + x[:name]) <=> 
      (description_or_blank(y.residence_location,'') +y[:name])
    end
    if location_col
      table_data = [['Location','Name', 'Email', 'Phone']]
    else
      table_data = [['Name', 'Email', 'Phone']]
    end
      
    location = ''
    families_by_location.each do |f|
      # Check for new residence location so we can group
      if location != description_or_blank(f.residence_location)   # same as previous location?
        location = description_or_blank(f.residence_location)  # no, start new grouping
        location = '??' if location.blank?
        displayed_location = location
        unless location_col  # Give new location its own row if it does not have its own column
          table_data << ["<b>#{location}</b>", '', ''] # Need enough columns to fill the row, or borders won't be right
        end  
      else
        displayed_location = ''  # not a new location, so don't show it in the location column (but what about top of page!?)
      end
      if location_col
        table_data << [displayed_location] + family_data_line(f, options.merge({:location=>'modifiers'}))
          # (we don't want locations displayed with each family in this part since they're displayed separately)
      else
        table_data << family_data_line(f, options.merge({:location=>nil}))
      end
    end

    bounding_box [0, cursor-20], :width => bounds.right-bounds.left, :height=> (cursor-20)-bounds.bottom-20 do

      table(table_data, :header => true, 
                      :row_colors => ["F0F0F0", "FFFFCC"],
                      :cell_style => { :size => 10, :inline_format => true}) do 
        row(0).style :background_color => 'CCCC00', :font => 'Times-Roman'
      end
      visitors_string = ''
      if ! visitors.empty?
        visitors_string = "\n<b>Visitors:</b>\n\n"
        a = visitors.map {|v| "#{v[:names]}: #{v[:contacts]} arrived #{v[:arrival_date].to_s(:short)}, " + 
          (v[:departure_date] ? " depart #{v[:departure_date].to_s(:short)}." : '')
          }
        visitors_string << a.join("\n")
        group {text visitors_string, :size=>9, :inline_format=>true}
      end
      
      # Part 2 -- Sorted by family
      table_data = [['<i>Name</i>', 'Email', 'Phone']]
      families.each do |f|
        table_data << family_data_line(f, options)
      end      
      start_new_page
      table(table_data, :header => true, 
                      :row_colors => ["F0F0F0", "FFFFCC"],
                      :cell_style => { :size => 10, :inline_format => true}) do 
        row(0).style :background_color => 'CCCC00', :font => 'Times-Roman'
        column(1).style :width=>150
      end
      group {text visitors_string, :size=>9, :inline_format=>true} unless visitors_string.empty?
 

    end # bounding_box


    render
  end
end
