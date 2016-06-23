require 'test_helper'

class ApiControllerTest < ActionController::TestCase
  test "should get autocomplete" do
    get :autocomplete
    assert_response :success
  end

  test "should get csv_dump" do
    get :csv_dump
    assert_response :success
  end

  test "should get help" do
    get :help
    assert_response :success
  end

end
