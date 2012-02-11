require 'test_helper'

class PopulationSubmissionAttachmentsControllerTest < ActionController::TestCase
  setup do
    @population_submission_attachment = population_submission_attachments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:population_submission_attachments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create population_submission_attachment" do
    assert_difference('PopulationSubmissionAttachment.count') do
      post :create, population_submission_attachment: @population_submission_attachment.attributes
    end

    assert_redirected_to population_submission_attachment_path(assigns(:population_submission_attachment))
  end

  test "should show population_submission_attachment" do
    get :show, id: @population_submission_attachment.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @population_submission_attachment.to_param
    assert_response :success
  end

  test "should update population_submission_attachment" do
    put :update, id: @population_submission_attachment.to_param, population_submission_attachment: @population_submission_attachment.attributes
    assert_redirected_to population_submission_attachment_path(assigns(:population_submission_attachment))
  end

  test "should destroy population_submission_attachment" do
    assert_difference('PopulationSubmissionAttachment.count', -1) do
      delete :destroy, id: @population_submission_attachment.to_param
    end

    assert_redirected_to population_submission_attachments_path
  end
end
