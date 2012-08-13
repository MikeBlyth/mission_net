class BloodtypesController < ApplicationController

  active_scaffold :bloodtype do |config|
    # list.columns.exclude :abo, :rh, :members
    list.columns = [:full, :comment]
    create.columns = update.columns = [:full, :abo, :rh, :comment]
    show.columns = [:full, :abo, :rh, :comment]
    list.sorting = {:full => 'ASC'}
    config.show.link = false
    config.update.link.confirm = "Are you sure you want to change a bloodtype definition"
    config.create.link.confirm = "Are you sure you want to add a new bloodtype definition"
    association_join_text = "; " 
    config.subform.columns.exclude :abo, :rh, :comment
    config.list.pagination = false
  end

  def list_authorized2?
    current_user.roles_include?(:member)
  end
end

