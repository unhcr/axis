class Ppg < ActiveRecord::Base
  attr_accessible :name

  has_and_belongs_to_many :goals
  has_and_belongs_to_many :plans

  has_many :indicator_data


end
