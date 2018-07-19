require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should sign up" do
    get signup_path
    assert_response :success
  end

end
