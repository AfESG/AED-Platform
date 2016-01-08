class Analysis < ActiveRecord::Base

  has_paper_trail

  has_many :input_zones, class_name: 'Change'

  attr_accessible(
    :analysis,
    :analysis_name,
    :analysis_year,
    :comparison_year
  )

end
