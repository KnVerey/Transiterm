class AddCleanDomainAndSourceToTermRecords < ActiveRecord::Migration
  def change
  	add_column :term_records, :clean_domain, :string
  	add_column :term_records, :clean_source, :string
  end
end
