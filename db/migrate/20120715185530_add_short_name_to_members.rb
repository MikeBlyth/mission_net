class AddShortNameToMembers < ActiveRecord::Migration
  def change
    add_column :members, :short_name, :string
  end
end
