class Submission < ActiveRecord::Base

  belongs_to :user

  has_many :population_submissions

  has_many :survey_aerial_sample_counts, :through => :population_submissions
  has_many :survey_aerial_total_counts, :through => :population_submissions
  has_many :survey_dung_count_line_transects, :through => :population_submissions
  has_many :survey_faecal_dnas, :through => :population_submissions
  has_many :survey_ground_sample_counts, :through => :population_submissions
  has_many :survey_ground_total_counts, :through => :population_submissions
  has_many :survey_individual_registrations, :through => :population_submissions
  has_many :survey_others, :through => :population_submissions

end
