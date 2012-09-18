class SystemNotesController < ApplicationController

skip_authorization_check

  active_scaffold :system_note do |config|
    config.columns = [:updated_at, :category, :note, :status]
    config.columns[:category].inplace_edit = true
    config.columns[:note].inplace_edit = true
    config.columns[:status].inplace_edit = true
  end

  def index
    @notices = I18n.t(:system_notes_prompt) 
    super
  end

end 
