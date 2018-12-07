require 'test_helper'

class Authentication::UnlocksControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get authentication_unlocks_new_url
    assert_response :success
  end

  test "should get show" do
    get authentication_unlocks_show_url
    assert_response :success
  end

end
