require 'test_helper'

class PaypalControllerTest < ActionDispatch::IntegrationTest
  test "should get paypal_sign_in" do
    get paypal_paypal_sign_in_url
    assert_response :success
  end

  test "should get paypal_auth" do
    get paypal_paypal_auth_url
    assert_response :success
  end

end
