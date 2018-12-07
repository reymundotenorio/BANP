require 'test_helper'

class Authentication::ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get authentication_confirmations_new_url
    assert_response :success
  end

  test "should get show" do
    get authentication_confirmations_show_url
    assert_response :success
  end

end
