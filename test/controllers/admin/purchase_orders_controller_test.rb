require 'test_helper'

class Admin::PurchaseOrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get admin_purchase_orders_new_url
    assert_response :success
  end

  test "should get index" do
    get admin_purchase_orders_index_url
    assert_response :success
  end

end
