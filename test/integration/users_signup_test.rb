require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "reject invalid signups" do
    assert_no_difference 'User.count' do 
      post sign_up_path params: {
        user: {
          name: "",
          email: "invalid@bar",
          password: "foo",
          password_confirmation: "bar" }}
    end
    assert_template 'users/new'
    assert_select '#error_explanation'
  end

  test "accept valid signups" do
    assert_difference 'User.count', 1 do 
      post sign_up_path params: {
        user: {
          name: "foobar",
          email: "foo@bar.com",
          password: "foobar",
          password_confirmation: "foobar" }}
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not_equal flash.count, 0
  end
end
