require 'spec_helper'

describe PasswordResetsController do
	describe "PATCH update" do
		context "when password field blank" do
			# This is a problem because if user is updating on their profile page, they are allowed to not change their password (leave both fields blank). This and that are both update methods, so same validations. Added custom code to controller, since save actually happens deep inside Sorcery.

			before(:each) do
				person = FactoryGirl.create(:user)
				User.stub(:load_from_reset_password_token).and_return(person)
			end

			it "throws a validation error" do
				patch :update, { id: "djljelwjflkwejfl", user: { password: "", password_confirmation: "" } }
				expect(assigns(:user).errors.count).to eq(1)
			end

			it "rerenders the password form" do
				patch :update, { id: "djljelwjflkwejfl", user: { password: "", password_confirmation: "" } }
				expect(response).to render_template("edit")
			end
		end
	end
end
