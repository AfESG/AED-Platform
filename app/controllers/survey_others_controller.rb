class SurveyOthersController < ApplicationController

  include CountCrud

  def new_child_path
    @level
  end

  def level_display
    nil
  end

  def level_form
    'layouts/survey_crud_form'
  end

end
