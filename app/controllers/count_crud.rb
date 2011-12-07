# Methods consistent across all Count level objects
module CountCrud

  include SurveyCrud

  # define the specific operation needed to connect the parent of
  # a newly created item in the new method
  def connect_parent
    @level.population_submission = PopulationSubmission.find(params[:population_submission_id])
  end

  # define the path to short-circuit to on creation of a new item
  # in the create method
  def new_child_path
    eval "new_#{level_base_name}_#{level_base_name}_stratum_path(@level)"
  end

end
