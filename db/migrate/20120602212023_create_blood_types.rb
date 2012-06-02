class CreateBloodTypes < ActiveRecord::Migration
  def change
    create_table :blood_types do |t|
      t.string :abo
      t.string :rh
      t.string :full

      t.timestamps
    end
  end
end
