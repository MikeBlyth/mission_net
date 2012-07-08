module ExportHelper
  require 'csv'

  # Create a multi-line CSV string from the "columns" of each record. The method is general and
  # records can be any array of objects that respond to columns as methods or attributes.
  # The first line of the CSV string is the column names (i.e. headers)
  # Example
  #    records = Member.where(...)
  #    export_csv(records, [last_name, first_name, name, birth_date ...]
  # gives (spaces added for clarity)
  #    last_name, first_name, name, birth_date
  #    Smith, Joshua, "Smith, Joshua (Josh)", 21 September 1980
  #    Ho, Juan, "Ho, Juan", 19 August 1990
  def export_csv(records, columns, params={})
    csv_string = CSV.generate(:force_quotes=>false, :headers=>columns, :write_headers=>true) do |csv|
      records.each do |r| 
        csv << columns.map do |c| 
          value = r.send(c.to_sym) if r.respond_to? c.to_sym
          # We want dates in long form, so have to convert them separately from other data types
          value.class == Date ? value.to_s(:long) : value.to_s
        end
      end
    end
    return csv_string
  end
  
  def export(cols=[], params={})
    return export_csv(self.all, cols, params)
  end

end

