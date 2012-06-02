class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.string :state
      t.string :city
      t.string :lga
      t.float :gps_latitude
      t.float :gps_longitude

      t.timestamps
    end
  end
end
