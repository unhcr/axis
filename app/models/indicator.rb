class Indicator < ActiveRecord::Base
  attr_accessible :is_gsp, :is_performance, :name

  has_and_belongs_to_many :outputs
  has_and_belongs_to_many :problem_objectives

  has_many :indicator_data
end
