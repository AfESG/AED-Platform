require 'test_helper'

class SurveyFaecalDnasControllerTest < ActionController::TestCase
  setup do
    @survey_faecal_dna = survey_faecal_dnas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:survey_faecal_dnas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create survey_faecal_dna" do
    assert_difference('SurveyFaecalDna.count') do
      post :create, :survey_faecal_dna => @survey_faecal_dna.attributes
    end

    assert_redirected_to survey_faecal_dna_path(assigns(:survey_faecal_dna))
  end

  test "should show survey_faecal_dna" do
    get :show, :id => @survey_faecal_dna.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @survey_faecal_dna.to_param
    assert_response :success
  end

  test "should update survey_faecal_dna" do
    put :update, :id => @survey_faecal_dna.to_param, :survey_faecal_dna => @survey_faecal_dna.attributes
    assert_redirected_to survey_faecal_dna_path(assigns(:survey_faecal_dna))
  end

  test "should destroy survey_faecal_dna" do
    assert_difference('SurveyFaecalDna.count', -1) do
      delete :destroy, :id => @survey_faecal_dna.to_param
    end

    assert_redirected_to survey_faecal_dnas_path
  end
end
