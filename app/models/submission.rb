class Submission < ActiveRecord::Base
  has_paper_trail

  # All normal attributes of this model are mass-assignable
  # except user_id which will be set in the controller
  attr_protected :created_at, :updated_at, :user_id

  validates_presence_of :country
  validates_presence_of :data_type

  belongs_to :user
  belongs_to :country
  belongs_to :species

  has_many :population_submissions, dependent: :destroy

  has_many :survey_aerial_sample_counts, :through => :population_submissions
  has_many :survey_aerial_total_counts, :through => :population_submissions
  has_many :survey_dung_count_line_transects, :through => :population_submissions
  has_many :survey_faecal_dnas, :through => :population_submissions
  has_many :survey_ground_sample_counts, :through => :population_submissions
  has_many :survey_ground_total_counts, :through => :population_submissions
  has_many :survey_individual_registrations, :through => :population_submissions
  has_many :survey_modeled_extrapolations, :through => :population_submissions
  has_many :survey_others, :through => :population_submissions

  belongs_to :country

  def range_states
    Species.find(1).range_states
  end

  class SubmissionValidator < ActiveModel::Validator
    def validate(record)
      if !record.species.nil? && record.species.scientific_name == "Loxodonta africana"
        if record.phenotype.blank?
          record.errors[:phenotype] << "must be answered if you are reporting on Loxodonta africana"
        elsif record.phenotype_basis.blank? && record.phenotype != 'Unknown'
          record.errors[:phenotype_basis] << "must be answered if you are reporting on Loxodonta africana"
        end
      end
      if record.right_to_grant_permission.nil?
        record.errors[:right_to_grant_permission] << "can't be blank"
      end
    end
  end

  validates_with SubmissionValidator
end
