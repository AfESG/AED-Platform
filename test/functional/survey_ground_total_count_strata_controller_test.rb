require 'test_helper'

class SurveyGroundTotalCountStrataControllerTest < ActionController::TestCase
  setup do
    @survey_ground_total_count_stratum = survey_ground_total_count_strata(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:survey_ground_total_count_strata)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create survey_ground_total_count_stratum" do
    assert_difference('SurveyGroundTotalCountStratum.count') do
      post :create, :survey_ground_total_count_stratum => @survey_ground_total_count_stratum.attributes
    end

    assert_redirected_to survey_ground_total_count_stratum_path(assigns(:survey_ground_total_count_stratum))
  end

  test "should show survey_ground_total_count_stratum" do
    get :show, :id => @survey_ground_total_count_stratum.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @survey_ground_total_count_stratum.to_param
    assert_response :success
  end

  test "should update survey_ground_total_count_stratum" do
    put :update, :id => @survey_ground_total_count_stratum.to_param, :survey_ground_total_count_stratum => @survey_ground_total_count_stratum.attributes
    assert_redirected_to survey_ground_total_count_stratum_path(assigns(:survey_ground_total_count_stratum))
  end

  test "should destroy survey_ground_total_count_stratum" do
    assert_difference('SurveyGroundTotalCountStratum.count', -1) do
      delete :destroy, :id => @survey_ground_total_count_stratum.to_param
    end

    assert_redirected_to survey_ground_total_count_strata_path
  end
end
