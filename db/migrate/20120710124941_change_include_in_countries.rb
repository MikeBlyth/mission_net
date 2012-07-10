class ChangeIncludeInCountries < ActiveRecord::Migration
  def change
    add_column :countries, :temp, :boolean
    Country.all.each {|c| c.update_attributes(:temp => (:include_in_selection == '1'))}
    remove_column :countries, :include_in_selection
    rename_column :countries, :temp, :include_in_selection
  end

end
