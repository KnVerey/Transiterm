require 'spec_helper'

describe User do
	let!(:katrina) { FactoryGirl.create(:user) }

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
end
