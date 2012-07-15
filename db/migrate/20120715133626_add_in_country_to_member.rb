class AddInCountryToMember < ActiveRecord::Migration
  def change
    add_column :members, :in_country, :boolean
    add_column :members, :comments, :string
  end
end
