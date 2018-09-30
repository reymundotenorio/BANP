require 'test_helper'

class Admin::Authentication::UnlocksControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get admin_authentication_unlocks_new_url
    assert_response :success
  end

  test "should get show" do
    get admin_authentication_unlocks_show_url
    assert_response :success
  end

end
