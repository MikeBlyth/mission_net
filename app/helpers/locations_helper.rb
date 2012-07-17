module LocationsHelper
  include ActionView::Helpers::FormOptionsHelper

    def code_with_description
      s = self.code.to_s + ' ' + self.description
      return s
    end

  # TODO: May be best to replace this with the Rails method that does the same thing.
  # http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-option_groups_from_collection_for_select
  def options_for_select_with_grouping(option_list, grouping_column, selected, value_column=:id, label_column=:description)
    options = ["<option value=''></option>"]
    groups = option_list.group_by{|opt| opt[grouping_column]}.sort_by { |k,v| k}
    groups.each do |group|
      group_label = group[0]
      options << "<optgroup label='#{group_label}'>"
      group_options = group[1].sort_by {|opt| opt[label_column]}
      group_options.each do |option|
        
        if option[value_column] == selected
          options <<  "<option value='#{option[value_column]}' selected='selected'>#{option[label_column]}<\/option>"
        else
          options <<  "<option value='#{option[value_column]}'>#{option[label_column]}<\/option>"
        end
      end
    end
    options
  end

  def location_choices(selected=999999)
  cities = City.where(true).order('name')
  return "<option value=''></option>" + 
      option_groups_from_collection_for_select(cities, :locations_sorted, 
          :name, :id, :description, selected)
  #  selections =  Location.select("id, city_id, description")
  #  hashed_locations = []
  #  selections.each do | selection |
  #    hashed_locations << {:id => selection.id, :city=>selection.city.name, :description => selection.description}
  #  end
  #  options_for_select_with_grouping(hashed_locations, :city, selected)
  end

end # Module


