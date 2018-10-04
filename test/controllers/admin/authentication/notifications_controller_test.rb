require 'test_helper'

class Admin::Authentication::NotificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get admin_authentication_notifications_new_url
    assert_response :success
  end

end
