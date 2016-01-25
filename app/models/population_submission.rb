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

  has_many :survey_aerial_sample_counts
  has_many :survey_aerial_sample_count_strata, :through => :survey_aerial_sample_counts

  has_many :survey_aerial_total_counts
  has_many :survey_aerial_total_count_strata, :through => :survey_aerial_total_counts

  has_many :survey_dung_count_line_transects
  has_many :survey_dung_count_line_transect_strata, :through => :survey_dung_count_line_transects

  has_many :survey_faecal_dnas
  has_many :survey_faecal_dna_strata, :through => :survey_faecal_dnas

  has_many :survey_ground_sample_counts
  has_many :survey_ground_sample_count_strata, :through => :survey_ground_sample_counts

  has_many :survey_ground_total_counts
  has_many :survey_ground_total_count_strata, :through => :survey_ground_total_counts

  has_many :survey_individual_registrations

  has_many :survey_others

  has_many :population_submission_attachments
  has_many :population_submission_geometries

  has_many :linked_citations

  @@mappings =
    {
      'AS' => 'survey_aerial_sample_count',
      'AT' => 'survey_aerial_total_count',
      'DC' => 'survey_dung_count_line_transect',
      'GD' => 'survey_faecal_dna',
      'GS' => 'survey_ground_sample_count',
      'GT' => 'survey_ground_total_count',
      'IR' => 'survey_individual_registration',
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
      '<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-sa/3.0/80x15.png" /></a>'
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

end
