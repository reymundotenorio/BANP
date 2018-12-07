require 'test_helper'

class Authentication::NotificationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get authentication_notifications_index_url
    assert_response :success
  end

end
