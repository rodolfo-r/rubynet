require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:user)
    @user2 = users(:user2)
  end

  test "reject invalid signups" do
    assert_no_difference 'User.count' do 
      post signup_path params: {
        user: {
          name: "",
          email: "invalid@bar",
          password: "foo",
          password_confirmation: "bar" }}
    end
    assert_template 'users/new'
    assert_select '#error_explanation'
  end

  test "signup with valid credentials followed by account activation" do
    assert_difference 'User.count', 1 do 
      post signup_path params: {
        user: {
          name: "foobar",
          email: "foo@bar.com",
          password: "foobar",
          password_confirmation: "foobar" }}
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_redirected_to user
    assert is_logged_in?
  end

  test "login with valid credentials followed by logout" do
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)

    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # Simulate a user clicking logout in a second window.
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
    log_in_as(@user, remember_me: 1)
    assert_not_empty cookies['remember_token']
  end

  test "login without remembering" do
    log_in_as(@user, remember_me: 1)
    log_in_as(@user, remember_me: 0)
    assert_empty cookies['remember_token']
  end

  test "invalid edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: {
      user: { name: "New Name",
              email: "",
              password: "",
              password_confirmation: "" } }
    assert_template 'users/edit'
    assert_select '#error_explanation'
  end

  test "successful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'

    name  = "New Name"
    email = "new@mail.com"
    patch user_path(@user), params: {
      user: { name: name,
              email: email,
              password: "",
              password_confirmation: "" } }

    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
    assert_not flash[:success].nil?
  end

  test "reject foreign user edits" do
    log_in_as(@user2)
    get edit_user_path(@user)
    assert_redirected_to root_url
    name  = "New Name"
    email = "new@mail.com"
    patch user_path(@user), params: {
      user: { name: name,
              email: email,
              password: "",
              password_confirmation: "" } }

    assert_redirected_to root_url
    @user.reload
    assert_not_equal name,  @user.name
    assert_not_equal email, @user.email
  end

  test "show activated users" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    User.where(activated: true).paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end

  test "do not show unactivated users" do
    log_in_as(@user)
    get users_path
    assert_select 'a[href=?]', user_path(@user2), count: 0
  end
end
