class Analysis < ActiveRecord::Base

  has_paper_trail

  has_many :input_zones, class_name: 'Change', dependent: :destroy

  attr_protected :created_at, :updated_at

  class << self
    def years
      { add: Analysis.all.pluck(:analysis_year), dpps: [2013, 2007, 2002, 1998, 1995] }
    end

    def latest_add_year
      years[:add].max
    end

    def latest_dpps_year
      years[:dpps].max
    end
  end
end
