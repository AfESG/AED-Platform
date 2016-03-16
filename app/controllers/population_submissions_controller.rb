require 'rgeo/geo_json'

class PopulationSubmissionsController < ApplicationController

  include SurveyCrud

  def index
    @population_submissions = view_context.recent_submissions_scope.order(translated_sort_column + ' ' + sort_direction);
    unless sort_column=='created_at'
      # always add a secondary sort, to enforce a guaranteed order
      @population_submissions = @population_submissions.order('created_at desc');
    end
    respond_to do |format|
      format.html
    end
  end

  def analysis_2013
    @population_submissions = PopulationSubmission.joins(:submission).joins('join countries on submissions.country_id=countries.id').where("population_submissions.id in (select population_submission_id from estimate_factors_analyses where analysis_name='2013_africa_final')").order(translated_sort_column + ' ' + sort_direction);
    unless sort_column=='created_at'
      # always add a secondary sort, to enforce a guaranteed order
      @population_submissions = @population_submissions.order('created_at desc');
    end
    respond_to do |format|
      format.html
    end
  end

  def my
    @population_submissions = PopulationSubmission.joins(:submission).where("submissions.user_id = ?",current_user.id).order('created_at desc')
    respond_to do |format|
      format.html
    end
  end

  # define the specific operation needed to connect the parent of
  # a newly created item in the new method
  def connect_parent
    @level.submission = Submission.find(params[:submission_id])
  end

  # define the path to short-circuit to on creation of a new item
  # in the create method
  def new_child_path
    eval "new_#{level_base_name}_#{@level.count_base_name}_path(@level)"
  end

  # Use our own view instead of the default supplied one.
  def level_display
    nil
  end

  def submit
    edit 'population_submissions/submit'
  end

  helper_method :sort_column, :sort_direction

  def sort_column
    params[:sort] || "id"
  end

  def translated_sort_column
    if sort_column=="country"
      "countries.name"
    else
      sort_column
    end
  end

  def sort_direction
    params[:direction] || "desc"
  end

  def geojson_map
    @level = level_class.find(params[:id])

    features = []
    if @level.counts[0].has_strata?
      @level.counts[0].strata.each do |stratum|
        if stratum.survey_geometry
          feature = RGeo::GeoJSON.encode(stratum.survey_geometry.geom)
          feature['properties'] = {
            'aed_stratum' => stratum.id,
            'aed_name' => stratum.stratum_name,
            'aed_area' => stratum.stratum_area,
            'aed_estimate' => stratum.population_estimate
          }
          features << feature
        end
      end
    else
      if @level.counts[0].survey_geometry
        c = @level.counts[0]
        feature = RGeo::GeoJSON.encode(c.survey_geometry.geom)
        feature['properties'] = {
          'single_stratum' => true,
          'aed_stratum' => c.id,
          'aed_name' => c.population_submission.site_name + ' ' + c.population_submission.designate,
          'aed_area' => c.population_submission.area,
          'aed_estimate' => (c.respond_to?(:population_estimate) && c.population_estimate) || c.population_estimate_min
        }
        features << feature
      end
    end
    @level.population_submission_geometries.each do |psg|
      feature = RGeo::GeoJSON.encode(psg.geom)
      feature['properties'] = {}
      if psg.geom_attributes and !psg.geom_attributes.blank?
        feature['properties'] = JSON.parse(psg.geom_attributes)
      end
      feature['properties']['aed_psg_id'] = psg.id
      if !@level.counts[0].has_strata?
        feature['properties']['single_stratum'] = true
      end
      features << feature
    end
    feature_collection = {
      'type' => 'FeatureCollection',
      'features' => features
    }
    render :json => feature_collection
  end

end
