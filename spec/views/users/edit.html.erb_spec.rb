require 'spec_helper'

describe "users/edit" do
  before(:each) do
    @user = assign(:user, stub_model(User,
      :email => "MyString",
      :crypted_password => "MyString",
      :salt => "MyString"
    ))
  end

  it "renders the edit user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", user_path(@user), "post" do
      assert_select "input#user_email[name=?]", "user[email]"
      assert_select "input#user_crypted_password[name=?]", "user[crypted_password]"
      assert_select "input#user_salt[name=?]", "user[salt]"
    end
  end
end
