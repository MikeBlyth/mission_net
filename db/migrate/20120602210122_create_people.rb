class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.integer :family_id
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.integer :country_id
      t.string :emergency_contact_phone
      t.string :emergency_contact_email
      t.string :emergency_contact_name
      t.string :phone_1
      t.string :phone_2
      t.string :email_1
      t.string :email_2
      t.integer :location_id
      t.string :location_detail
      t.date :arrival_date
      t.date :departure_date
      t.boolean :receive_sms
      t.boolean :receive_email
      t.boolean :blood_donor
      t.integer :blood_type_id
      t.timestamps
    end
  end
end
