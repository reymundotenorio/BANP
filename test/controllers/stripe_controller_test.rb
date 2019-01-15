require 'test_helper'

class StripeControllerTest < ActionDispatch::IntegrationTest
  test "should get checkout" do
    get stripe_checkout_url
    assert_response :success
  end

end
