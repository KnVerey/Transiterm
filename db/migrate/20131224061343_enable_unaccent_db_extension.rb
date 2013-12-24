class EnableUnaccentDbExtension < ActiveRecord::Migration
  def change
  	ActiveRecord::Base.connection.execute 'CREATE EXTENSION unaccent;'
  end
end