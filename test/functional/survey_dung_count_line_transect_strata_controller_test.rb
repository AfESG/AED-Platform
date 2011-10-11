require 'test_helper'

class SurveyDungCountLineTransectStrataControllerTest < ActionController::TestCase
  setup do
    @survey_dung_count_line_transect_stratum = survey_dung_count_line_transect_strata(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:survey_dung_count_line_transect_strata)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create survey_dung_count_line_transect_stratum" do
    assert_difference('SurveyDungCountLineTransectStratum.count') do
      post :create, :survey_dung_count_line_transect_stratum => @survey_dung_count_line_transect_stratum.attributes
    end

    assert_redirected_to survey_dung_count_line_transect_stratum_path(assigns(:survey_dung_count_line_transect_stratum))
  end

  test "should show survey_dung_count_line_transect_stratum" do
    get :show, :id => @survey_dung_count_line_transect_stratum.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @survey_dung_count_line_transect_stratum.to_param
    assert_response :success
  end

  test "should update survey_dung_count_line_transect_stratum" do
    put :update, :id => @survey_dung_count_line_transect_stratum.to_param, :survey_dung_count_line_transect_stratum => @survey_dung_count_line_transect_stratum.attributes
    assert_redirected_to survey_dung_count_line_transect_stratum_path(assigns(:survey_dung_count_line_transect_stratum))
  end

  test "should destroy survey_dung_count_line_transect_stratum" do
    assert_difference('SurveyDungCountLineTransectStratum.count', -1) do
      delete :destroy, :id => @survey_dung_count_line_transect_stratum.to_param
    end

    assert_redirected_to survey_dung_count_line_transect_strata_path
  end
end
