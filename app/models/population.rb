class Population < ActiveRecord::Base
  self.primary_key = :id
  belongs_to :country
  has_many :input_zones
end
