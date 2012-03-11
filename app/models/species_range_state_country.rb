class SpeciesRangeStateCountry < ActiveRecord::Base
  # this model is not mass-assignable
  attr_accessible

  belongs_to :species
  belongs_to :country
end
