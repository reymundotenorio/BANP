require 'test_helper'

class Authentication::PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get authentication_passwords_new_url
    assert_response :success
  end

  test "should get show" do
    get authentication_passwords_show_url
    assert_response :success
  end

end
