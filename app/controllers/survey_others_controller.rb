class SurveyOthersController < ApplicationController

  include CountCrud

  def new_child_path
    @level
  end

end
