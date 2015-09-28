require 'spec_helper'

describe User do
	let!(:person) { FactoryGirl.create(:active_user) }

  it 'must have a first name' do
  	user = User.new
  	expect(user.first_name).to be_nil
  	expect(user).not_to be_valid
  end

  it 'should have saved user to db if valid fields provided' do
  	expect(person.first_name).not_to be_nil
  end

  it 'should have default active languages set' do
    expect(person.french_active).to be true
    expect(person.english_active).to be true
    expect(person.spanish_active).to be false
  end

  describe "toggle_language" do

    it "toggles the language specified as arg" do
      user = FactoryGirl.build(:active_user, french_active: true)
      user.toggle_language("french")
      expect(user.french_active).to be false
    end

    it "persists the change" do
      user = FactoryGirl.create(:active_user, french_active: true)
      expect(user).to receive(:save)
      user.toggle_language("french")
    end
  end

  describe "language_statuses" do
    it "returns a hash with three items" do
      user = FactoryGirl.build(:user, french_active: true, english_active: false, spanish_active: false)
      expect(user.language_statuses.kind_of? Hash).to be true
      expect(user.language_statuses.length).to eq(3)
    end

    it "correctly records the active languages" do
      user = FactoryGirl.build(:user, french_active: true, english_active: true, spanish_active: false)
      expect(user.language_statuses[:french]).to eq(true)
      expect(user.language_statuses[:english]).to eq(true)
      expect(user.language_statuses[:spanish]).to eq(false)
    end
  end

  describe "active_languages=" do
    it "changes user langs to match the set passed in" do
      user = FactoryGirl.build(:active_user)
      user.active_languages = ["spanish"]
      expect(user.active_languages).to match_array(["spanish"])
    end
  end

end
