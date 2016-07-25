class ApiController < ApplicationController
  include StrataDataHelper

  caches_action :strata_geojson,
                :known_geojson,
                :possible_geojson,
                :doubtful_geojson,
                :protected_geojson,
                expires: 24.hours,
                cache_path: Proc.new { |c| c.params.keep_if { |k,v| %w(simplify strcode) }}

  def autocomplete
    list = {}
    Continent.where(name: 'Africa').each do |c|
      list[c.name] = {
          id: c.id,
          geographicType: 'continent',
          parent: nil
      }
    end
    Region.all.each do |r|
      list[r.name] = {
          id: r.id,
          geographicType: 'region',
          parent: r.continent.name
      }
    end
    Country.where.not(region: nil).each do |c|
      list[c.name] = {
          id: c.iso_code,
          geographicType: 'country',
          parent: c.region.name
      }
    end
    sql = "SELECT DISTINCT
             input_zone_id,
             stratum_name || ' (' || analysis_year || ')' AS name,
             country
           FROM estimate_locator
           WHERE analysis_year < 2015"
    execute(sql).each do |s|
      list[s['name']] = {
          id: s['input_zone_id'],
          geographicType: 'stratum',
          parent: s['country']
      }
    end
    render json: list
  end

  def add_dump
    respond_to do |format|
      format.json { render json: Country.add_dump }
      format.csv { send_data(Country.add_csv_dump, filename: 'add_dump.csv') }
    end
  end

  def boilerplate_dump
    year = Analysis.latest_add_year
    africa = Continent.find_by_name('Africa')
    regions = africa.regions.to_a.delete_if { |r| r.countries.count == 0 }.sort_by(&:name)
    countries = regions.map(&:countries).flatten.delete_if { |c| !c.is_surveyed }.sort_by(&:name) # TODO exclude these?

    respond_to do |format|
      format.json do
        render json: {
            continents: [{ 'Africa': africa.narrative_boilerplate(year) }],
            regions: regions.reduce({}) { |o, r| o[r.name] = r.narrative_boilerplate(year); o },
            countries: countries.reduce({}) { |o, c| o[c.name] = c.narrative_boilerplate(year); o }
        }
      end

      format.text do
        ''
      end
    end
  end

  def help
  end

  def strata_geojson
    if simplify > 0.0
      sql = 'SELECT ST_AsGeoJSON(ST_SimplifyPreserveTopology(sg.geom, ?), 10) as "geo" FROM estimate_factors ef
             LEFT JOIN survey_geometries sg ON (ef.survey_geometry_id = sg.id)
             WHERE ef.input_zone_id = ?'
      geojson = execute(sql, simplify, strcode).first['geo']
    else
      sql = 'SELECT ST_AsGeoJSON(sg.geom, 10) as "geo" FROM estimate_factors ef
             LEFT JOIN survey_geometries sg ON (ef.survey_geometry_id = sg.id)
             WHERE ef.input_zone_id = ?'
      geojson = execute(sql, strcode).first['geo']
    end
    render json: geojson
  end

  def strata_data
    render json: get_strata_data(strcode)
  end

  def known_geojson
    if simplify > 0.0
      sql = 'SELECT ST_AsGeoJSON(ST_SimplifyPreserveTopology(geometry, ?), 10) as "geo" FROM range_geometries
           WHERE range = ? AND rangequali = ? AND geometry IS NOT NULL'
      result = execute(sql, simplify, 1, 'Known')
    else
      sql = 'SELECT ST_AsGeoJSON(geometry, 10) as "geo" FROM range_geometries
           WHERE range = ? AND rangequali = ? AND geometry IS NOT NULL'
      result = execute(sql, 1, 'Known')
    end
    render json: {
        type: 'GeometryCollection',
        geometries: result.map { |r| JSON.parse(r['geo']) }
    }
  end

  def possible_geojson
    if simplify > 0.0
      sql = 'SELECT ST_AsGeoJSON(ST_SimplifyPreserveTopology(geometry, ?), 10) as "geo" FROM range_geometries
           WHERE range = ? AND rangequali = ? AND geometry IS NOT NULL'
      result = execute(sql, simplify, 1, 'Possible')
    else
      sql = 'SELECT ST_AsGeoJSON(geometry, 10) as "geo" FROM range_geometries
           WHERE range = ? AND rangequali = ? AND geometry IS NOT NULL'
      result = execute(sql, 1, 'Possible')
    end
    render json: {
        type: 'GeometryCollection',
        geometries: result.map { |r| JSON.parse(r['geo']) }
    }
  end

  def doubtful_geojson
    if simplify > 0.0
      sql = 'SELECT ST_AsGeoJSON(ST_SimplifyPreserveTopology(geometry, ?), 10) as "geo" FROM range_geometries
           WHERE range = ? AND rangequali = ? AND geometry IS NOT NULL'
      result = execute(sql, simplify, 0, 'Possible')
    else
      sql = 'SELECT ST_AsGeoJSON(geometry, 10) as "geo" FROM range_geometries
           WHERE range = ? AND rangequali = ? AND geometry IS NOT NULL'
      result = execute(sql, 0, 'Possible')
    end
    render json: {
        type: 'GeometryCollection',
        geometries: result.map { |r| JSON.parse(r['geo']) }
    }
  end

  def protected_geojson
    if simplify > 0.0
      sql = 'SELECT ST_AsGeoJSON(ST_SimplifyPreserveTopology(geometry, ?), 10) as "geo" FROM protected_area_geometries
           WHERE geometry IS NOT NULL'
      result = execute(sql, simplify)
    else
      sql = 'SELECT ST_AsGeoJSON(geometry, 10) as "geo" FROM protected_area_geometries
           WHERE geometry IS NOT NULL'
      result = execute(sql)
    end
    render json: {
        type: 'GeometryCollection',
        geometries: result.map { |r| JSON.parse(r['geo']) }
    }
  end

  private
  def execute(*array)
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    ActiveRecord::Base.connection.execute(sql)
  end

  def simplify
    params[:simplify].to_f * 0.1
  end

  def strcode
    params[:strcode].upcase
  end
end
