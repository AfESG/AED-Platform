class Change < ActiveRecord::Base

  attr_accessible(
    :change,
    :analysis_year,
    :country,
    :replacement_name,
    :replaced_strata,
    :new_strata,
    :reason_change
  )

end
