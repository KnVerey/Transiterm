require 'spec_helper'

describe User do
	let!(:person) { FactoryGirl.create(:active_user) }

  it 'must have a first name' do
  	user = User.new
  	user.first_name.should == nil
  	user.first_name.should_not == "something"
  	user.should_not be_valid
  end

  it 'should have saved user to db if valid fields provided' do
  	person.first_name.should_not == nil
  end

  it 'should have default active languages set' do
    expect(person.french_active).to be_true
    expect(person.english_active).to be_true
    expect(person.spanish_active).to be_false
  end

  describe "toggle_language" do

    it "toggles the language specified as arg" do
      user = FactoryGirl.build(:active_user, french_active: true)
      user.toggle_language("french")
      expect(user.french_active).to be_false
    end

    it "persists the change" do
      user = FactoryGirl.create(:active_user, french_active: true)
      expect(user).to receive(:save)
      user.toggle_language("french")
    end
  end

  describe "toggle_collection" do
    it "adds the collection to the list if it isn't there" do
      expect {
        person.toggle_collection("1")
      }.to change(person.active_collection_ids, :length).by(1)
    end

    it "removes the collection from the list if it is there" do
      person.active_collection_ids << 1

      expect {
        person.toggle_collection("1")
      }.to change(person.active_collection_ids, :length).by(-1)
    end

    context "when 'all' is received" do
      it "removes all collections from the list that match all the user's currently active languages"

      it "does not remove collections from the list that partially match the user's active languages"

      it "does not remove collections from the list that match none of the user's active languages"

    end

  end

  describe "active_languages" do
    context "with one active language" do
      it "reports an array of one language" do
        user = FactoryGirl.build(:user, french_active: true, english_active: false, spanish_active: false)
        expect(user.active_languages.kind_of? Array).to be_true
        expect(user.active_languages.length).to eq(1)
      end
    end

    context "with two active languages" do
      it "reports an array of two languages" do
        user = FactoryGirl.build(:user, french_active: true, english_active: true, spanish_active: false)
        expect(user.active_languages.kind_of? Array).to be_true
        expect(user.active_languages.length).to eq(2)
      end
    end

    context "with three active languages" do
      it "reports an array of two languages" do
        user = FactoryGirl.build(:user, french_active: true, english_active: true, spanish_active: true)
        expect(user.active_languages.kind_of? Array).to be_true
        expect(user.active_languages.length).to eq(3)
      end
    end
  end
end
