class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.integer :parent_group_id
      t.string :description
      t.boolean :primary

      t.timestamps
    end
  end
end
