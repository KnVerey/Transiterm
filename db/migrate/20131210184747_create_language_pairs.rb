class CreateLanguagePairs < ActiveRecord::Migration
  def change
    create_table :language_pairs do |t|
    	t.string :language1
    	t.string :language2
    end
  end
end
