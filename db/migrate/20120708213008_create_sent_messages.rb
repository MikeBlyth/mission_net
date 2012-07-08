class CreateSentMessages < ActiveRecord::Migration
  def change
    create_table :sent_messages do |t|
      t.integer :message_id
      t.integer :member_id
      t.integer :msg_status
      t.datetime :confirmed_time
      t.string :delivery_modes
      t.string :confirmed_mode
      t.string :confirmation_message
      t.integer :attempts
      t.string :gateway_message_id

      t.timestamps
    end
  end
end
