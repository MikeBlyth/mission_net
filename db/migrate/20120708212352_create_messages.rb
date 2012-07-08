class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :body
      t.integer :from_id
      t.string :code
      t.integer :confirm_time_limit
      t.integer :retries
      t.integer :retry_interval
      t.integer :expiration
      t.integer :response_time_limit
      t.integer :importance
      t.integer :to_groups
      t.boolean :send_email
      t.boolean :send_sms
      t.integer :user_id
      t.string :subject
      t.string :sms_only
      t.integer :following_up

      t.timestamps
    end
  end
end
