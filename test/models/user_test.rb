require 'test_helper'

class UserTest < ActiveSupport::TestCase
 def setup
   @user = User.new(name: "John", email: "john@beatles.com",
                   password: "secret", password_confirmation: "secret")
 end

 test "should be valid" do
    assert @user.valid?
  end

 test "should contain name" do
   @user.name = " "
   assert_not @user.valid?
 end

 test "should contain email" do
   @user.email = " "
   assert_not @user.valid?
 end

 test "validate valid emails" do
   emails = %w[foo@bar.com foo_bar@baz.com
   foo.bar@baz.com foo123@bar.com]
   emails.each do |email|
     @user.email = email
     assert @user.valid?, "#{email} should be valid"
   end
 end

 test "invalidate invalid emails" do
   emails = %w[foo.bar.com foo@bar@baz.com
   foo@bar foo$@bar.com]
   emails.each do |email|
     @user.email = email
     assert_not @user.valid?, "#{email} should be invalid"
   end
 end

 test "unique emails" do
   @user.save
   new_user = @user.dup
   new_user.email.upcase!
   assert_not new_user.valid?
 end

 test "save emails as downcase" do
   @user.email = "FOO@bar.com"
   @user.save
   @user.reload
   assert_equal @user.email, @user.email.downcase
 end

 test "user should contain password" do
   @user.password = " "
   assert_not @user.valid?
 end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
end
