class PlansProblemObjectives < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :problem_objective
  belongs_to :plan
end
