class Population < ActiveRecord::Base
  self.primary_key = :id
  belongs_to :country
  has_many :input_zones

  def to_s
    name
  end

  def as_json(options = nil)
    super({ except: [:geom] }.merge(options || {}))
  end

  def geojson
    RGeo::GeoJSON.encode(geom)
  end
end
