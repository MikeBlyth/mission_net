module LocationsHelper
  include ActionView::Helpers::FormOptionsHelper

  def code_with_description
    s = self.code.to_s + ' ' + self.description
    return s
  end

  def location_choices(selected)
  cities = City.where(true).order('name')
    options = option_groups_from_collection_for_select(cities, :locations_sorted, 
            :name, :id, :description, selected)
    return options
  end

end # Module


