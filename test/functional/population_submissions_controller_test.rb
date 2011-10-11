require 'test_helper'

class PopulationSubmissionsControllerTest < ActionController::TestCase
  setup do
    @population_submission = population_submissions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:population_submissions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create population_submission" do
    assert_difference('PopulationSubmission.count') do
      post :create, :population_submission => @population_submission.attributes
    end

    assert_redirected_to population_submission_path(assigns(:population_submission))
  end

  test "should show population_submission" do
    get :show, :id => @population_submission.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @population_submission.to_param
    assert_response :success
  end

  test "should update population_submission" do
    put :update, :id => @population_submission.to_param, :population_submission => @population_submission.attributes
    assert_redirected_to population_submission_path(assigns(:population_submission))
  end

  test "should destroy population_submission" do
    assert_difference('PopulationSubmission.count', -1) do
      delete :destroy, :id => @population_submission.to_param
    end

    assert_redirected_to population_submissions_path
  end
end
