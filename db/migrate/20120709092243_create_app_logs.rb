class CreateAppLogs < ActiveRecord::Migration
  def self.up
    create_table :app_logs do |t|
      t.string :severity
      t.string :code
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :app_logs
  end
end
