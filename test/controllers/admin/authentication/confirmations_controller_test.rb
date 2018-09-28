require 'test_helper'

class Admin::Authentication::ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get admin_authentication_confirmations_new_url
    assert_response :success
  end

  test "should get show" do
    get admin_authentication_confirmations_show_url
    assert_response :success
  end

end
