class InputZone < ActiveRecord::Base
  self.primary_key = :id
  belongs_to :population

  def to_s
    name
  end

  def as_json(options = nil)
    super({ except: [:geom] }.merge(options || {}))
  end

  def strata(year)
    sql = 'SELECT * FROM input_zone_export WHERE trim(inpzone) = ? and ayear = ?'
    execute(sql, name, year)
  end

  def geojson
    RGeo::GeoJSON.encode(geom)
  end

  private
  def self.execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    ActiveRecord::Base.connection.execute(sql)
  end

  def execute(*array)
    self.class.execute(*array)
  end
end
