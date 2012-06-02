class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :code
      t.string :name
      t.string :nationality
      t.string :include_in_selection

      t.timestamps
    end
  end
end
