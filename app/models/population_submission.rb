class PopulationSubmission < ActiveRecord::Base
  has_paper_trail

  # All normal attributes of this model are mass-assignable
  attr_protected :created_at, :updated_at

  validates_presence_of :data_licensing
  validates_presence_of :site_name
  validates_presence_of :designate
  validates_presence_of :area
  validates_presence_of :completion_year
  validates_presence_of :season
  validates_presence_of :survey_type

  class PopulationSubmissionValidator < ActiveModel::Validator
    def validate(record)
      if record.released?
        unless record.submitted?
          record.errors[:submitted] << "must be submitted in order to be released"
        end
        if record.short_citation.blank?
          record.errors[:short_citation] << "must be supplied in order to be released"
        end
      end
    end
  end

  validates_with PopulationSubmissionValidator

  belongs_to :submission

  has_many :survey_aerial_sample_counts, dependent: :destroy
  has_many :survey_aerial_sample_count_strata, :through => :survey_aerial_sample_counts

  has_many :survey_aerial_total_counts, dependent: :destroy
  has_many :survey_aerial_total_count_strata, :through => :survey_aerial_total_counts

  has_many :survey_dung_count_line_transects, dependent: :destroy
  has_many :survey_dung_count_line_transect_strata, :through => :survey_dung_count_line_transects

  has_many :survey_faecal_dnas, dependent: :destroy
  has_many :survey_faecal_dna_strata, :through => :survey_faecal_dnas

  has_many :survey_ground_sample_counts, dependent: :destroy
  has_many :survey_ground_sample_count_strata, :through => :survey_ground_sample_counts

  has_many :survey_ground_total_counts, dependent: :destroy
  has_many :survey_ground_total_count_strata, :through => :survey_ground_total_counts

  has_many :survey_individual_registrations, dependent: :destroy

  has_many :survey_modeled_extrapolations, dependent: :destroy

  has_many :survey_others, dependent: :destroy

  has_many :population_submission_attachments, dependent: :destroy
  has_many :population_submission_geometries, dependent: :destroy

  has_many :linked_citations, dependent: :destroy

  @@mappings =
    {
      'AS' => 'survey_aerial_sample_count',
      'AT' => 'survey_aerial_total_count',
      'DC' => 'survey_dung_count_line_transect',
      'GD' => 'survey_faecal_dna',
      'GS' => 'survey_ground_sample_count',
      'GT' => 'survey_ground_total_count',
      'IR' => 'survey_individual_registration',
      'ME' => 'survey_modeled_extrapolation',
      'O' => 'survey_other'
    }

  @@friendly_names =
    {
      'AS' => 'an aerial sample count',
      'AT' => 'an aerial total count',
      'DC' => 'a dung count',
      'GD' => 'a faecal DNA survey',
      'GS' => 'a ground sample count',
      'GT' => 'a ground total count',
      'IR' => 'an individual_registration',
      'ME' => 'a modeled extrapolation',
      'O' => 'an "other" description'
    }

  def count_friendly_name
    @@friendly_names[survey_type]
  end

  def count_base_name
    @@mappings[survey_type]
  end

  def counts
    eval "#{count_base_name.pluralize}"
  end

  def to_s
    "#{site_name} #{designate}"
  end

  # FIXME this straight-sum approach is incomplete
  # also, PostgreSQL should be doing this
  def estimate
    e = 0
    @@mappings.each do |k,v|
      counts = eval v.pluralize
      counts.each do |obj|
        if obj.respond_to? 'population_estimate'
          e = e + obj.population_estimate
        elsif obj.respond_to? 'population_estimate_min'
          # handles the Other case which just has a range
          e = e + obj.population_estimate_min
        else
          strata = eval "obj.#{v}_strata"
          strata.each do |stratum|
            e = e + stratum.population_estimate
          end
        end
      end
    end
    e
  end

  def source
    short_citation
  end

  def data_licensing_link
    if data_licensing =~ /CC/
      '<a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-sa/4.0/80x15.png" /></a>'
    else
      'Report restricted by data provider'
    end
  end

  def can_see_attachments(user)
    unless user.nil?
      return true if user.admin?
    end
    if data_licensing == 'CC'
      return true
    end
    unless embargo_date.nil?
      if embargo_date < DateTime.now
        return true
      end
    end
    return false
  end

  def self.recalculate_centroids
    PopulationSubmission.order(:id).each do |population_submission|
      if population_submission.latitude or population_submission.longitude
        puts "Keeping existing coordinate: #{population_submission.latitude}, #{population_submission.longitude}"
      else
        puts "Need to calculate coordinate"
        count = population_submission.counts[0]
        if count
          if count.has_strata?
            puts "  Count has strata"
            lat_agg = 0
            long_agg = 0
            n = 0
            count.strata.each do |stratum|
              survey_geometry = stratum.survey_geometry
              if survey_geometry and survey_geometry.geom
                puts "   Stratum long: #{survey_geometry.geom.centroid.x}"
                long_agg = long_agg + survey_geometry.geom.centroid.x
                puts "   Stratum lat: #{survey_geometry.geom.centroid.y}"
                lat_agg = lat_agg + survey_geometry.geom.centroid.y
                n = n + 1
              else
                puts "  Stratum has no geometry, staying empty"
              end
            end
            if n > 0
              long = long_agg / n
              lat = lat_agg / n
              puts "   Derived long: #{long}"
              puts "   Derived lat: #{lat}"
              population_submission.latitude = lat
              population_submission.longitude = long
              population_submission.save!
            end
          else
            puts "  Count has no strata"
            survey_geometry = count.survey_geometry
            if survey_geometry and survey_geometry.geom
              puts "   Derived long: #{survey_geometry.geom.centroid.x}"
              puts "   Derived lat: #{survey_geometry.geom.centroid.y}"
              population_submission.latitude = survey_geometry.geom.centroid.y
              population_submission.longitude = survey_geometry.geom.centroid.x
              population_submission.save!
            else
              puts "  Count has no geometry, staying empty"
            end
          end
        end
      end
    end
  end

end
