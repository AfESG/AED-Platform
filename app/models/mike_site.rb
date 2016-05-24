class MikeSite < ActiveRecord::Base
  has_paper_trail

  # this model is not web-serviceable
  attr_accessible

  belongs_to :country
  has_many :survey_aerial_sample_count_strata
  has_many :survey_aerial_total_count_strata
  has_many :survey_dung_count_line_transect_strata
  has_many :survey_faecal_dna_strata
  has_many :survey_ground_sample_count_strata
  has_many :survey_ground_total_count_strata
  has_many :survey_individual_registrations
  has_many :survey_modeled_extrapolations
  has_many :survey_others

  default_scope { order('site_code ASC') } 

  def to_s
    "#{site_code} #{site_name}"
  end
end
