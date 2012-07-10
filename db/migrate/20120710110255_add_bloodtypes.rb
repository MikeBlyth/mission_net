class AddBloodtypes < ActiveRecord::Migration
  def up
  drop_table :blood_types
  create_table "bloodtypes", :force => true do |t|
    t.string   "abo"
    t.string   "rh"
    t.string   "full"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "comment"
  end
  end

  def down
  end
end
