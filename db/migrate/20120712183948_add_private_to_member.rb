class AddPrivateToMember < ActiveRecord::Migration
  def change
    add_column :members, :phone_private, :boolean
    add_column :members, :email_private, :boolean
  end
end
