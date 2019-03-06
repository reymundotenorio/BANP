require 'test_helper'

class TrackingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get trackings_index_url
    assert_response :success
  end

  test "should get show" do
    get trackings_show_url
    assert_response :success
  end

end
