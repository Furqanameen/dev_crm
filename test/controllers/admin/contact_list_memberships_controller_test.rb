require "test_helper"

class Admin::ContactListMembershipsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get admin_contact_list_memberships_create_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_contact_list_memberships_destroy_url
    assert_response :success
  end

  test "should get bulk_add" do
    get admin_contact_list_memberships_bulk_add_url
    assert_response :success
  end
end
