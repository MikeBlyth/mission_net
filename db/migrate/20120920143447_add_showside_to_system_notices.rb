class AddShowsideToSystemNotices < ActiveRecord::Migration
  def change
    add_column :system_notes, :show_in_sidebar, :boolean
  end
end
