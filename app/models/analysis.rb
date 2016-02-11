class Analysis < ActiveRecord::Base

  has_paper_trail

  has_many :input_zones, class_name: 'Change', dependent: :destroy

  attr_protected :created_at, :updated_at

end
