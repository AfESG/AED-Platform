class Species < ActiveRecord::Base

  # this model is not web-serviceable
  attr_accessible

  has_many :species_range_state_countries
  has_many :range_states, :through => :species_range_state_countries, :source => 'country', :order => 'name'
  def to_s
    scientific_name
  end
end
