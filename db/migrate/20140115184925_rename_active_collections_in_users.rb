class RenameActiveCollectionsInUsers < ActiveRecord::Migration
  def change
  	rename_column :users, :active_collections, :active_collection_ids
  end
end
