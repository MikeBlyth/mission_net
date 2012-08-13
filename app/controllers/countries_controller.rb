class CountriesController < ApplicationController
  helper :countries

  load_and_authorize_resource
  
  active_scaffold :country do |config|
    config.columns = [:name, :nationality, :include_in_selection, :code]
    config.show.link = false
    config.update.link.confirm = "Are you sure you want to change this country?"
    list.sorting = {:name => 'ASC'}
    config.subform.columns.exclude :nationality, :code, :members
    config.subform.columns.exclude :nationality, :code, :members
    config.columns[:include_in_selection].inplace_edit = true
  end

  def list_authorized2?
    current_user.roles_include?(:member)
  end
end  

