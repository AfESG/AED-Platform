require 'test_helper'

class SurveyFaecalDnaStrataControllerTest < ActionController::TestCase
  setup do
    @survey_faecal_dna_stratum = survey_faecal_dna_strata(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:survey_faecal_dna_strata)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create survey_faecal_dna_stratum" do
    assert_difference('SurveyFaecalDnaStratum.count') do
      post :create, :survey_faecal_dna_stratum => @survey_faecal_dna_stratum.attributes
    end

    assert_redirected_to survey_faecal_dna_stratum_path(assigns(:survey_faecal_dna_stratum))
  end

  test "should show survey_faecal_dna_stratum" do
    get :show, :id => @survey_faecal_dna_stratum.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @survey_faecal_dna_stratum.to_param
    assert_response :success
  end

  test "should update survey_faecal_dna_stratum" do
    put :update, :id => @survey_faecal_dna_stratum.to_param, :survey_faecal_dna_stratum => @survey_faecal_dna_stratum.attributes
    assert_redirected_to survey_faecal_dna_stratum_path(assigns(:survey_faecal_dna_stratum))
  end

  test "should destroy survey_faecal_dna_stratum" do
    assert_difference('SurveyFaecalDnaStratum.count', -1) do
      delete :destroy, :id => @survey_faecal_dna_stratum.to_param
    end

    assert_redirected_to survey_faecal_dna_strata_path
  end
end
