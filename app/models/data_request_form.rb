class DataRequestForm < ActiveRecord::Base

  attr_accessible(
    :name,
    :title,
    :department,
    :organization,
    :telephone,
    :fax,
    :email,
    :website,
    :address,
    :town,
    :post_code,
    :state,
    :country,
    :extracts,
    :research,
    :subset_other,
    :status
  )

  validates_presence_of(
    :name,
    :title,
    :department,
    :organization,
    :email,
    :address,
    :country,
    :extracts,
    :research
  )

end
