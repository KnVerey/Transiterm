require 'spec_helper'

describe SourcesController do
  let(:person) { FactoryGirl.create(:active_user) }

  describe "GET index" do
    it "redirects if user not logged in" do
      get :index
      expect(response).to redirect_to("/login")
    end

    it "does not respond to HTML" do
      login_user(person)
      expect {
        get :index
      }.to raise_error(ActionController::UnknownFormat)
    end

    it "responds to JSON with array of matching source names" do
      login_user(person)
      FactoryGirl.create(:source, user: person, name: "Cats")
      FactoryGirl.create(:source, user: person, name: "Kitty Cats")
      get :index, format: :json

      expect(response.body[0]).to eq("[")
      expect(response.body.split(",").length).to eq(2)
    end
  end
end
