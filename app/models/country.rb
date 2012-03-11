class Country < ActiveRecord::Base

  # this model is not web-serviceable
  attr_accessible

  has_many :species, :through => :species_range_state_countries, :source => :species_range_state_country
  has_many :mike_sites
  def to_s
    name
  end
end
