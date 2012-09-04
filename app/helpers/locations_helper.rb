module LocationsHelper
  include ActionView::Helpers::FormOptionsHelper

  def location_choices(selected)
    cities = City.where(true).order('name')
    options = option_groups_from_collection_for_select(cities, :locations_sorted, 
            :name, :id, :description, selected)
#puts "**** options=#{options}"
    return options
  end

end # Module


