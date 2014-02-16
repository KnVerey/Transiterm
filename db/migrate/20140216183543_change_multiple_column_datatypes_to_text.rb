class ChangeMultipleColumnDatatypesToText < ActiveRecord::Migration
  def change
  	change_column :term_records, :english, :text
  	change_column :term_records, :french, :text
  	change_column :term_records, :spanish, :text
  	change_column :term_records, :context, :text
  	change_column :term_records, :comment, :text
  	change_column :term_records, :clean_english, :text
  	change_column :term_records, :clean_french, :text
  	change_column :term_records, :clean_spanish, :text
  	change_column :term_records, :clean_context, :text
  	change_column :term_records, :clean_comment, :text
  	change_column :term_records, :clean_domain, :text
  	change_column :term_records, :clean_source, :text

  	change_column :domains, :name, :text
  	change_column :domains, :clean_name, :text

  	change_column :sources, :name, :text
  	change_column :sources, :clean_name, :text
  end
end
