# Methods consistent across all Stratum level objects
module StratumCrud

  include SurveyCrud

  # define the specific operation needed to connect the parent of
  # a newly created item in the new method
  def connect_parent
    id_param = params["#{@level.count_base_name}_id"]
    eval "@level.#{@level.count_base_name} = @level.count_class.find(id_param)"
  end

  def index
    raise ActiveRecord::RecordNotFound
  end
end
