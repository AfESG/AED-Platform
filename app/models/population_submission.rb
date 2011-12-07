class PopulationSubmission < ActiveRecord::Base
  validates_presence_of :data_licensing
  validates_presence_of :site_name
  validates_presence_of :designate
  validates_presence_of :area
  validates_presence_of :completion_year
  validates_presence_of :season
  validates_presence_of :survey_type

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

end
