require 'test_helper'

class SurveyIndividualRegistrationsControllerTest < ActionController::TestCase
  setup do
    @survey_individual_registration = survey_individual_registrations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:survey_individual_registrations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create survey_individual_registration" do
    assert_difference('SurveyIndividualRegistration.count') do
      post :create, :survey_individual_registration => @survey_individual_registration.attributes
    end

    assert_redirected_to survey_individual_registration_path(assigns(:survey_individual_registration))
  end

  test "should show survey_individual_registration" do
    get :show, :id => @survey_individual_registration.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @survey_individual_registration.to_param
    assert_response :success
  end

  test "should update survey_individual_registration" do
    put :update, :id => @survey_individual_registration.to_param, :survey_individual_registration => @survey_individual_registration.attributes
    assert_redirected_to survey_individual_registration_path(assigns(:survey_individual_registration))
  end

  test "should destroy survey_individual_registration" do
    assert_difference('SurveyIndividualRegistration.count', -1) do
      delete :destroy, :id => @survey_individual_registration.to_param
    end

    assert_redirected_to survey_individual_registrations_path
  end
end
