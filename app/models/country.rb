class Country < ActiveRecord::Base
  has_many :species, :through => :species_range_state_countries, :source => :species_range_state_country
  def to_s
    name
  end
end
