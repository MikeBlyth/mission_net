class CreateSystemNotes < ActiveRecord::Migration
  def change
    create_table :system_notes do |t|
      t.string :category
      t.string :note
      t.string :status
      t.timestamps
    end
  end
end
