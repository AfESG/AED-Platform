class Analysis < ActiveRecord::Base

  has_paper_trail

  has_many :input_zones, class_name: 'Change', dependent: :destroy

  attr_protected :created_at, :updated_at

  scope :published, -> { where(is_published: true) }
  scope :not_published, -> { where(is_published: true) }

  class << self
    def years
      { add: AedUtils.analysis_years, dpps: AedUtils.all_analysis_years}
    end

    def latest_add_year
      years[:add].max
    end

    def latest_dpps_year
      years[:dpps].max
    end
  end
end
