class ProblemObjectivesStrategies < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :strategy
  belongs_to :problem_objective
end
