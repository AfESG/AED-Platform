require 'test_helper'

class ReportNarrativesControllerTest < ActionController::TestCase
  setup do
    @report_narrative = report_narratives(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:report_narratives)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create report_narrative" do
    assert_difference('ReportNarrative.count') do
      post :create, report_narrative: @report_narrative.attributes
    end

    assert_redirected_to report_narrative_path(assigns(:report_narrative))
  end

  test "should show report_narrative" do
    get :show, id: @report_narrative.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @report_narrative.to_param
    assert_response :success
  end

  test "should update report_narrative" do
    put :update, id: @report_narrative.to_param, report_narrative: @report_narrative.attributes
    assert_redirected_to report_narrative_path(assigns(:report_narrative))
  end

  test "should destroy report_narrative" do
    assert_difference('ReportNarrative.count', -1) do
      delete :destroy, id: @report_narrative.to_param
    end

    assert_redirected_to report_narratives_path
  end
end
