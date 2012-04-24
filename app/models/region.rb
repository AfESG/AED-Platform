class Region < ActiveRecord::Base
  belongs_to :continent
  has_many :countries
end
