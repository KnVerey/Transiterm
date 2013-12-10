class CreateTermRecords < ActiveRecord::Migration
  def change
    create_table :term_records do |t|
      t.string :english
      t.string :french
      t.string :spanish
      t.string :context
      t.string :comment
      t.integer :domain_id
      t.integer :source_id
      t.integer :collection_id

      t.timestamps
    end
  end
end
