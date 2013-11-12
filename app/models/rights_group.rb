class RightsGroup < ActiveRecord::Base
  attr_accessible :name

  has_many :problem_objectives
  has_many :indicator_data

  belongs_to :goal
end
