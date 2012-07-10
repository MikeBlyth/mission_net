module MembersHelper
#  def member_id_form_column(record, options)
#    "Here we are!"
#    collection_select(:record, :state_id, State.find(:all, :order => "name"), :id, :name, {}, options)
#  end

  def options_for_association_conditions(association)
    if [:health_data, :personnel_data].include? association.name 
      ['false']
    else
      super
    end
  end
  
  def members_column(family)
    family_data_formatted(family, :include_contacts => false)[:first_names]
  end
  
#  def reported_location_time_column(record)
#    record.reported_location_time#.to_s#(:date_time_short)
#  end

  # Needed to suppress the 'Replace with new record' button on edit page
  def column_show_add_new(column, associated, record)
          true if column != :personnel_data &&
                  column != :health_data 
  end

#  def self.authorized_for_create?
#    false # or some test for current user
#  end


  def spouse_column(record)
    if record.spouse
      record.spouse.short_name || record.spouse.first_name
    else
      "-"
    end  
  end

  def work_location_form_column(record, params)
    result = "<select id='record_work_location' name='record[work_location]' class='work_location-input'>"
    result << location_choices(@record[:work_location_id])
#puts "**** #{@record[:work_location_id]}, #{@record.attributes}, record--#{record[:work_location_id]}, #{record.attributes}"
    result << "</select>"
    return raw(result) 
  end

  def spouse_form_column(record,params)
    # Generate the select input ourselves
    result = "<select id='record_spouse' name='record[spouse]' class='spouse-input'>" + 
             "<option class='spouse-input' value=''>--None--</option>"

    record.possible_spouses.each do |p|
      if record.spouse_id == p.id
        selected = "selected='selected'"
      else
        selected = ''
      end
      result << "<option class='spouse-input' value='#{p.id}' #{selected}>#{p.to_label}</option>"
    end
    result << "<option class='spouse-input' value=''>--Other--</option></select>"
    # Mismatched spouses?
    # ! This logic should go in controller, but we need to find ActiveScaffold callback
    # !   in order to place it there.
    if !record.new_record? && record.spouse_id && record.spouse && record.spouse.spouse_id != record.id
      my_name = record.full_name_short
      spouse_name = record.spouse.full_name_short
      spouse_first_name = record.spouse.first_name
      result << "<p class='alert'>Mismatched spouses: #{my_name}" +
                    " shows #{spouse_name} as spouse but #{spouse_first_name} shows " 
      if record.spouse.spouse_id.nil?
        result << "no spouse." 
      else
        result << "#{record.spouse.spouse.full_name_short} as spouse."
      end  
      result << "</p><p class='alert'>If you save this record still showing a spouse, " +
            "<em>that</em> person's record will be updated automatically to show #{record.first_name} as " +
            "<em>his</em> or <em>her</em> spouse.</p>"
    end
#puts "* --- #{result}"
    return raw(result)
  end

end
