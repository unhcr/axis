class PlansProblemObjectives < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :problem_objectives
  belongs_to :plan
end
