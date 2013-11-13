class ProblemObjective < ActiveRecord::Base
  attr_accessible :is_excluded, :objective_name, :problem_name

  has_many :indicator_data
  has_many :budget_lines

  has_and_belongs_to_many :outputs
  has_and_belongs_to_many :indicators
  has_and_belongs_to_many :rights_groups
end
