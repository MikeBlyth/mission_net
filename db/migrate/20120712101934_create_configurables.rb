class CreateConfigurables < ActiveRecord::Migration
  def self.up
    create_table :site_settings do |t|
      t.string :name
      t.string :value

      t.timestamps
    end
    
    add_index :site_settings, :name
  end

  def self.down
    remove_index :site_settings, :name
    drop_table :site_settings
  end
end
