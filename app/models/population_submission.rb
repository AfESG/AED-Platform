class PopulationSubmission < ActiveRecord::Base
  validates_presence_of :data_licensing
  validates_presence_of :site_name
  validates_presence_of :designate
  validates_presence_of :area
  validates_presence_of :completion_year
  validates_presence_of :completion_month
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

end
