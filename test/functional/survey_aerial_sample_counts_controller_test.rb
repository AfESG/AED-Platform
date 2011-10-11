require 'test_helper'

class SurveyAerialSampleCountsControllerTest < ActionController::TestCase
  setup do
    @survey_aerial_sample_count = survey_aerial_sample_counts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:survey_aerial_sample_counts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create survey_aerial_sample_count" do
    assert_difference('SurveyAerialSampleCount.count') do
      post :create, :survey_aerial_sample_count => @survey_aerial_sample_count.attributes
    end

    assert_redirected_to survey_aerial_sample_count_path(assigns(:survey_aerial_sample_count))
  end

  test "should show survey_aerial_sample_count" do
    get :show, :id => @survey_aerial_sample_count.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @survey_aerial_sample_count.to_param
    assert_response :success
  end

  test "should update survey_aerial_sample_count" do
    put :update, :id => @survey_aerial_sample_count.to_param, :survey_aerial_sample_count => @survey_aerial_sample_count.attributes
    assert_redirected_to survey_aerial_sample_count_path(assigns(:survey_aerial_sample_count))
  end

  test "should destroy survey_aerial_sample_count" do
    assert_difference('SurveyAerialSampleCount.count', -1) do
      delete :destroy, :id => @survey_aerial_sample_count.to_param
    end

    assert_redirected_to survey_aerial_sample_counts_path
  end
end
