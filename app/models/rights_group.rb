class RightsGroup < ActiveRecord::Base
  attr_accessible :name

  has_and_belongs_to_many :problem_objectives
  has_and_belongs_to_many :goals

  has_many :indicator_data
end
