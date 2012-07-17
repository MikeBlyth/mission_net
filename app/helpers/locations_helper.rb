module LocationsHelper
  include ActionView::Helpers::FormOptionsHelper

    def code_with_description
      s = self.code.to_s + ' ' + self.description
      return s
    end

  def location_choices(selected)
  cities = City.where(true).order('name')
  return "<option value=''></option>" + 
      option_groups_from_collection_for_select(cities, :locations_sorted, 
          :name, :id, :description, selected)
  end

end # Module


