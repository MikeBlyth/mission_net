class AddLockedToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :user_selectable, :boolean
  end
end
