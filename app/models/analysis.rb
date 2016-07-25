class Analysis < ActiveRecord::Base

  has_paper_trail

  has_many :input_zones, class_name: 'Change', dependent: :destroy

  attr_protected :created_at, :updated_at

  YEARS = { add: [2015, 2013], dpps: [2013, 2007, 2002, 1998, 1995] }
end
