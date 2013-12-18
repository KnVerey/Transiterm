class AddActiveLanguagesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :french_active, :boolean, default: true
    add_column :users, :english_active, :boolean, default: true
    add_column :users, :spanish_active, :boolean, default: false
  end
end
