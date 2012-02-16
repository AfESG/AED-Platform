class SurveyIndividualRegistrationsController < ApplicationController

  include CountCrud

  def new_child_path
    eval "edit_individual_registration_path(@level)"
  end

end
