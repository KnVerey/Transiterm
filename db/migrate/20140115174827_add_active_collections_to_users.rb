class AddActiveCollectionsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :active_collections, :integer, array: true, default: []
  end
end
