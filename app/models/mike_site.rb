class MikeSite < ActiveRecord::Base
  # this model is not web-serviceable
  attr_accessible

  belongs_to :country
end
