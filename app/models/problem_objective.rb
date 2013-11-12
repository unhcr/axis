class ProblemObjective < ActiveRecord::Base
  attr_accessible :is_excluded, :objective_name, :problem_name

  has_many :outputs
  has_many :indicator_data

  has_and_belongs_to_many :indicators

  belongs_to :rights_group
end
