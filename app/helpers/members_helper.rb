module MembersHelper

  # Needed to suppress the 'Replace with new record' button on edit page
  def column_show_add_new(column, associated, record)
          true if column != :personnel_data &&
                  column != :health_data 
  end

end
