class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :name
      t.text :description
      t.integer :language1_id
      t.integer :language2_id
      t.integer :field1_id
      t.integer :field2_id
      t.boolean :sharable

      t.integer :user_id

      t.timestamps
    end
  end
end
