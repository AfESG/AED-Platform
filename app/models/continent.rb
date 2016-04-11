class Continent < ActiveRecord::Base
  has_many :regions

  def countries
    Country.where(region: self.regions)
  end
end
