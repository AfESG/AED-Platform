class ReportNarrative < ActiveRecord::Base
  has_paper_trail

  attr_accessible(
    :uri,
    :narrative,
    :footnote
  )

end
