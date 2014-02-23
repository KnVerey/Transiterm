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
      context "when all are not already active" do
        it "adds the ids returned by the finder method to the list" do
          person.active_collection_ids.push(3)
          User.any_instance.stub(:find_all_ids_in_lang_combo).and_return([1, 2])

          person.toggle_collection("all")
          expect(person.active_collection_ids).to include(1)
          expect(person.active_collection_ids).to include(2)
        end

        it "does not add additional collections to the list" do
          person.active_collection_ids.push(3)
          User.any_instance.stub(:find_all_ids_in_lang_combo).and_return([1])

          person.toggle_collection("all")
          expect(person.active_collection_ids.sort).to eq([1, 3])
        end

        it "does not allow duplicates in the list" do
          person.active_collection_ids.push(3)
          User.any_instance.stub(:find_all_ids_in_lang_combo).and_return([1, 3])

          person.toggle_collection("all")
          expect(person.active_collection_ids.sort).to eq([1, 3])
        end
      end

      context "when all are already active" do
        it "removes the ids returned by the finder method from the list" do
          person.active_collection_ids.push(1, 2, 3)
          User.any_instance.stub(:find_all_ids_in_lang_combo).and_return([1, 2, 3])

          person.toggle_collection("all")
          expect(person.active_collection_ids).to be_empty
        end

        it "leaves any other collections in the list" do
          person.active_collection_ids.push(1, 2, 3)
          User.any_instance.stub(:find_all_ids_in_lang_combo).and_return([2, 3])

          person.toggle_collection("all")
          expect(person.active_collection_ids).to eq([1])
        end
      end
    end

  end

  describe "find_all_ids_in_lang_combo" do
    it "finds all collections with lang combo matching user's currently active langs" do
      en_fr1 = FactoryGirl.create(:collection, user: person)
      en_fr2 = FactoryGirl.create(:collection, user: person)
      en_fr_sp = FactoryGirl.create(:three_lang_collection, user: person)
      en_sp = FactoryGirl.create(:collection, english: true, spanish: true, french: false, user: person)
      sp = FactoryGirl.create(:collection, english: false, french: false, spanish: true, user: person)

      expect(person.send(:find_all_ids_in_lang_combo)).to eq([en_fr1.id, en_fr2.id])
    end
  end

  describe "language_statuses" do
    it "returns a hash with three items" do
      user = FactoryGirl.build(:user, french_active: true, english_active: false, spanish_active: false)
      expect(user.language_statuses.kind_of? Hash).to be_true
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
    it "toggles user langs to match the set passed in" do
      user = FactoryGirl.build(:active_user)
      user.active_languages = ["spanish"]
      expect(user.active_languages).to match_array(["spanish"])
    end
  end

end
