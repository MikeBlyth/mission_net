class CreateMemberGroupJoinTable < ActiveRecord::Migration
  def up
    create_table :groups_members, :id => false do |t|
      t.integer :group_id
      t.integer :member_id
    end
  end

  def down
  end
end
