class AddCommentsToBloodtype < ActiveRecord::Migration
  def change
    add_column :blood_types, :comment, :string
  end
end
