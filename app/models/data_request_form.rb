class DataRequestForm < ActiveRecord::Base

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
