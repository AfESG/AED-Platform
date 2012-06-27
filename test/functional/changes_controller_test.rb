require 'test_helper'

class ChangesControllerTest < ActionController::TestCase
  setup do
    @change = changes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:changes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create change" do
    assert_difference('Change.count') do
      post :create, change: @change.attributes
    end

    assert_redirected_to change_path(assigns(:change))
  end

  test "should show change" do
    get :show, id: @change
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @change
    assert_response :success
  end

  test "should update change" do
    put :update, id: @change, change: @change.attributes
    assert_redirected_to change_path(assigns(:change))
  end

  test "should destroy change" do
    assert_difference('Change.count', -1) do
      delete :destroy, id: @change
    end

    assert_redirected_to changes_path
  end
end
