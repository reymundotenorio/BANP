require 'test_helper'

class Admin::Purchases::ReturnsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_purchases_returns_index_url
    assert_response :success
  end

end
