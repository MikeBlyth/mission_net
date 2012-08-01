class AddPrivToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :administrator, :boolean
    add_column :groups, :moderator, :boolean
    add_column :groups, :member, :boolean
    add_column :groups, :limited, :boolean
  end
end
