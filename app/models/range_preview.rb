class RangePreview < ActiveRecord::Base

  has_paper_trail

  attr_accessible(
    :status,
    :comments
  )

end
