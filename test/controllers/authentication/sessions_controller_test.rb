require 'test_helper'

class Authentication::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get authentication_sessions_new_url
    assert_response :success
  end

  test "should get two_factor" do
    get authentication_sessions_two_factor_url
    assert_response :success
  end

end
