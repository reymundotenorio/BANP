require 'test_helper'

class Admin::Authentication::NotificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_authentication_notifications_index_url
    assert_response :success
  end

end
