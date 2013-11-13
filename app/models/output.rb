class Output < ActiveRecord::Base
  attr_accessible :name, :priority

  has_and_belongs_to_many :indicators
  has_and_belongs_to_many :problem_objectives

  has_many :indicator_data
  has_many :budget_lines
end
