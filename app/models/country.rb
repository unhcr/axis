class Country < ActiveRecord::Base
  attr_accessible :latlng, :iso, :un_names, :name, :iso3, :iso2, :region, :subregion

  # lat, lng of center
  serialize :latlng, Array
  serialize :un_names, Array

  has_many :plans
end
