class Population < ActiveRecord::Base
  belongs_to :country
  has_many :input_zones
end
