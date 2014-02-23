class MoveActivityStatusToCollection < ActiveRecord::Migration
  def change
  	remove_column :users, :active_collection_ids, :integer, array: true, default: []
  	add_column :collections, :active, :boolean, default: true
  end
end
