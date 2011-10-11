require 'test_helper'

class SurveyOthersControllerTest < ActionController::TestCase
  setup do
    @survey_other = survey_others(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:survey_others)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create survey_other" do
    assert_difference('SurveyOther.count') do
      post :create, :survey_other => @survey_other.attributes
    end

    assert_redirected_to survey_other_path(assigns(:survey_other))
  end

  test "should show survey_other" do
    get :show, :id => @survey_other.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @survey_other.to_param
    assert_response :success
  end

  test "should update survey_other" do
    put :update, :id => @survey_other.to_param, :survey_other => @survey_other.attributes
    assert_redirected_to survey_other_path(assigns(:survey_other))
  end

  test "should destroy survey_other" do
    assert_difference('SurveyOther.count', -1) do
      delete :destroy, :id => @survey_other.to_param
    end

    assert_redirected_to survey_others_path
  end
end
