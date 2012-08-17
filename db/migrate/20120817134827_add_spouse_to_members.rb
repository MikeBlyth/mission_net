class AddSpouseToMembers < ActiveRecord::Migration
  def change
    add_column :members, :wife_id, :integer
    add_column :members, :sex, :string
  end
end
