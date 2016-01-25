class LinkedCitation < ActiveRecord::Base
  has_paper_trail

  belongs_to :population_submission
end
