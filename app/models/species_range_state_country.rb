class SpeciesRangeStateCountry < ActiveRecord::Base
  has_paper_trail

  # this model is not mass-assignable
  attr_accessible

  belongs_to :species
  belongs_to :country
end
