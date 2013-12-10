class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :title
      t.text :description
      t.integer :language_pair_id
      t.integer :user_id

      t.timestamps
    end
  end
end
