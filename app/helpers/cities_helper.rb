module CitiesHelper
  def column_show_add_new(column, associated, record)
    return false
          true if column != :personnel_data &&
                  column != :health_data 
  end

end
