class MikeSite < ActiveRecord::Base
  has_paper_trail

  # this model is not web-serviceable
  attr_accessible

  belongs_to :country
end
