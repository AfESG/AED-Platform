class MikeSite < ActiveRecord::Base
  has_paper_trail

  # this model is not web-serviceable
  attr_accessible

  belongs_to :country
  has_many :submissions

  default_scope :order => 'site_code ASC'

  def to_s
    "#{site_code} #{site_name}"
  end
end
