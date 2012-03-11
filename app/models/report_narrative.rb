class ReportNarrative < ActiveRecord::Base

  attr_accessible(
    :uri,
    :narrative,
    :footnote
  )

end
