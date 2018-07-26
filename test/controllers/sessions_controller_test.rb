require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user)
  end
  
  test "should get new" do
    get login_url
    assert_response :success
  end

  test "error on invalid login" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: {
      session: {
        email: "foo@bar.com",
        password: "password" }}
    assert_template 'sessions/new'
    assert flash.any?
  end

  test "should login on valid credentials" do
    post login_path, params: {
      session: {
        email: @user.email,
        password: "password" }}
    assert_redirected_to @user
    follow_redirect!
    assert_select "a[href=?]", logout_path
  end

  test "should logout" do
    post login_path, params: {
      session: {
        email: @user.email,
        password: "password" }}
    follow_redirect!
    delete logout_path
    assert_redirected_to root_path
  end
end
