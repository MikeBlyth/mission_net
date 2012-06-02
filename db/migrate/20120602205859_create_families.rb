class CreateFamilies < ActiveRecord::Migration
  def change
    create_table :families do |t|
      t.integer :head_id
      t.timestamps
    end
  end
end
