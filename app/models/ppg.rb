class Ppg < ActiveRecord::Base
  attr_accessible :name

  self.primary_key = :id

  has_and_belongs_to_many :goals
  has_and_belongs_to_many :plans

  has_many :indicator_data
end
