require "test_helper"

class Admin::MessageEventsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_message_events_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_message_events_show_url
    assert_response :success
  end
end
