require 'test_helper'

class SurveyDungCountLineTransectsControllerTest < ActionController::TestCase
  setup do
    @survey_dung_count_line_transect = survey_dung_count_line_transects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:survey_dung_count_line_transects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create survey_dung_count_line_transect" do
    assert_difference('SurveyDungCountLineTransect.count') do
      post :create, :survey_dung_count_line_transect => @survey_dung_count_line_transect.attributes
    end

    assert_redirected_to survey_dung_count_line_transect_path(assigns(:survey_dung_count_line_transect))
  end

  test "should show survey_dung_count_line_transect" do
    get :show, :id => @survey_dung_count_line_transect.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @survey_dung_count_line_transect.to_param
    assert_response :success
  end

  test "should update survey_dung_count_line_transect" do
    put :update, :id => @survey_dung_count_line_transect.to_param, :survey_dung_count_line_transect => @survey_dung_count_line_transect.attributes
    assert_redirected_to survey_dung_count_line_transect_path(assigns(:survey_dung_count_line_transect))
  end

  test "should destroy survey_dung_count_line_transect" do
    assert_difference('SurveyDungCountLineTransect.count', -1) do
      delete :destroy, :id => @survey_dung_count_line_transect.to_param
    end

    assert_redirected_to survey_dung_count_line_transects_path
  end
end
