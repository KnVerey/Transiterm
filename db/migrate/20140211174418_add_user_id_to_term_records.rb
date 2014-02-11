class AddUserIdToTermRecords < ActiveRecord::Migration
  def change
    add_column :term_records, :user_id, :integer
  end
end
