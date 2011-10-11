require 'test_helper'

class SurveyGroundTotalCountsControllerTest < ActionController::TestCase
  setup do
    @survey_ground_total_count = survey_ground_total_counts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:survey_ground_total_counts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create survey_ground_total_count" do
    assert_difference('SurveyGroundTotalCount.count') do
      post :create, :survey_ground_total_count => @survey_ground_total_count.attributes
    end

    assert_redirected_to survey_ground_total_count_path(assigns(:survey_ground_total_count))
  end

  test "should show survey_ground_total_count" do
    get :show, :id => @survey_ground_total_count.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @survey_ground_total_count.to_param
    assert_response :success
  end

  test "should update survey_ground_total_count" do
    put :update, :id => @survey_ground_total_count.to_param, :survey_ground_total_count => @survey_ground_total_count.attributes
    assert_redirected_to survey_ground_total_count_path(assigns(:survey_ground_total_count))
  end

  test "should destroy survey_ground_total_count" do
    assert_difference('SurveyGroundTotalCount.count', -1) do
      delete :destroy, :id => @survey_ground_total_count.to_param
    end

    assert_redirected_to survey_ground_total_counts_path
  end
end
