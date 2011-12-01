class SpeciesRangeStateCountry < ActiveRecord::Base
  belongs_to :species
  belongs_to :country
end
