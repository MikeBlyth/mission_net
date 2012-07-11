class AddContactsToSentMessages < ActiveRecord::Migration
  def change
    add_column :sent_messages, :phone, :string
    add_column :sent_messages, :email, :string
  end
end
