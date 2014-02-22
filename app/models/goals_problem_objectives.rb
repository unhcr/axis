class GoalsProblemObjectives < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :goal
  belongs_to :problem_objective
end
