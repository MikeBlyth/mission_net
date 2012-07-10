class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :group_name
      t.integer :parent_group_id
      t.string :abbrev
      t.boolean :primary

      t.timestamps
    end
  end
end
