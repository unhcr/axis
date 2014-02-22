class ProblemObjectivesStrategyObjectives < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :strategy_objective
  belongs_to :problem_objective
end
