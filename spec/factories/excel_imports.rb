FactoryGirl.define do
  factory :excel_import do

  	initialize_with { new() }

  	factory :valid_excel_import do
	    initialize_with { new(user: FactoryGirl.create(:user), file: ActionDispatch::Http::UploadedFile.new(:tempfile => File.new("#{Rails.root}/spec/fixtures/valid_import.xls"), :filename => "valid_import.xls")) }
  	end

  	factory :invalid_excel_import do
	    initialize_with { new(user: FactoryGirl.create(:user), file: ActionDispatch::Http::UploadedFile.new(:tempfile => File.new("#{Rails.root}/spec/fixtures/invalid_import.xls"), :filename => "invalid_import.xls")) }
  	end

  	factory :invalid_file_type_excel_import do
	    initialize_with { new(user: FactoryGirl.create(:user), file: ActionDispatch::Http::UploadedFile.new(:tempfile => File.new("#{Rails.root}/spec/fixtures/invalid_import.xlsx"), :filename => "invalid_import.xlsx")) }
  	end
  end
end
