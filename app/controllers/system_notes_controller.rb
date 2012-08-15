class SystemNotesController < ApplicationController
  active_scaffold :system_note do |config|
    config.columns = [:updated_at, :category, :note, :status]
    config.columns[:category].inplace_edit = true
    config.columns[:note].inplace_edit = true
    config.columns[:status].inplace_edit = true
  end

  def index
    @notices = "Create a new entry if you find a bug or problem or just have a suggestion. Category is optional and status is for developer use."
    super
  end
  

end 
