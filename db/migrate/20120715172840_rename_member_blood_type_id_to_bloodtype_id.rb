class RenameMemberBloodTypeIdToBloodtypeId < ActiveRecord::Migration
  def up
    rename_column :members, :blood_type_id, :bloodtype_id
  end

  def down
    rename_column :members, :bloodtype_id, :blood_type_id
  end
end
