require 'test_helper'

class Admin::PurchaseDetailsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get admin_purchase_details_show_url
    assert_response :success
  end

end
