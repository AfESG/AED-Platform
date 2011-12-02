class Species < ActiveRecord::Base
  has_many :species_range_state_countries
  has_many :range_states, :through => :species_range_state_countries, :source => 'country', :order => 'name'
end
