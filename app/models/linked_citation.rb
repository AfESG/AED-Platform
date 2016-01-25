class LinkedCitation < ActiveRecord::Base
  has_paper_trail

  attr_accessible(
    :population_submission_id,
    :linked_citation,
    :short_citation,
    :long_citation,
    :url,
    :description
  )

  belongs_to :population_submission
end
