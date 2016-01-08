class Analysis < ActiveRecord::Base

  has_paper_trail

  has_many :changes

  attr_accessible(
    :analysis,
    :analysis_name,
    :analysis_year,
    :comparison_year
  )

end
