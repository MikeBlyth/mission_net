class AddKeywordsToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :keywords, :string
    add_column :messages, :news_update, :boolean
    add_column :messages, :private, :boolean
  end
end
