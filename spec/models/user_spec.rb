require 'spec_helper'

describe User do
	let!(:katrina) { FactoryGirl.create(:active_user) }

  it 'must have a first name' do
  	user = User.new
  	user.first_name.should == nil
  	user.first_name.should_not == "something"
  	user.should_not be_valid
  end

  it 'should have saved user to db if valid fields provided' do
  	katrina.first_name.should_not == nil
  end

  it 'should have default active languages set' do
    expect(katrina.french_active).to be_true
    expect(katrina.english_active).to be_true
    expect(katrina.spanish_active).to be_false
  end

  describe "toggle_language" do

    it "toggles the language specified as arg" do
      user = FactoryGirl.build(:user, french_active: true)
      user.toggle_language("french")
      expect(user.french_active).to be_false
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
