class Species < ActiveRecord::Base
  has_paper_trail

  # this model is not web-serviceable
  attr_accessible

  has_many :species_range_state_countries, dependent: :destroy
  has_many :range_states, -> {
      order 'name'
    }, :through => :species_range_state_countries,
    :source => 'country'
  has_many :submissions, dependent: :destroy

  def to_s
    scientific_name
  end
end
