class RedoTheEntireCollectionTable < ActiveRecord::Migration
  def change
  	add_column :collections, :english, :boolean
  	add_column :collections, :french, :boolean
  	add_column :collections, :spanish, :boolean

  	remove_column :collections, :language_pair_id
  end
end
