require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should sign up" do
    get sign_up_path
    assert_response :success
  end

end
