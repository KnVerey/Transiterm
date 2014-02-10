class AddCleanColumnsForSearch < ActiveRecord::Migration
  def change
  	add_column :domains, :clean_name, :string
  	add_column :sources, :clean_name, :string

  	add_column :term_records, :clean_english, :string
  	add_column :term_records, :clean_french, :string
  	add_column :term_records, :clean_spanish, :string
  	add_column :term_records, :clean_context, :string
  	add_column :term_records, :clean_comment, :string
  end
end
