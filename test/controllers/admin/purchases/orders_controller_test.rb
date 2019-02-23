require 'test_helper'

class Admin::Purchases::OrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_purchases_orders_index_url
    assert_response :success
  end

end
