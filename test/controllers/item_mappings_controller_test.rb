require 'test_helper'

class ItemMappingsControllerTest < ActionController::TestCase
  setup do
    @item_mapping = item_mappings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:item_mappings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create item_mapping" do
    assert_difference('ItemMapping.count') do
      post :create, item_mapping: { big_basket_url: @item_mapping.big_basket_url, error: @item_mapping.error, hopcom_name: @item_mapping.hopcom_name, item_id: @item_mapping.item_id, item_variety_id: @item_mapping.item_variety_id, kmv_name: @item_mapping.kmv_name, remark: @item_mapping.remark, unit_id: @item_mapping.unit_id }
    end

    assert_redirected_to item_mapping_path(assigns(:item_mapping))
  end

  test "should show item_mapping" do
    get :show, id: @item_mapping
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @item_mapping
    assert_response :success
  end

  test "should update item_mapping" do
    patch :update, id: @item_mapping, item_mapping: { big_basket_url: @item_mapping.big_basket_url, error: @item_mapping.error, hopcom_name: @item_mapping.hopcom_name, item_id: @item_mapping.item_id, item_variety_id: @item_mapping.item_variety_id, kmv_name: @item_mapping.kmv_name, remark: @item_mapping.remark, unit_id: @item_mapping.unit_id }
    assert_redirected_to item_mapping_path(assigns(:item_mapping))
  end

  test "should destroy item_mapping" do
    assert_difference('ItemMapping.count', -1) do
      delete :destroy, id: @item_mapping
    end

    assert_redirected_to item_mappings_path
  end
end
