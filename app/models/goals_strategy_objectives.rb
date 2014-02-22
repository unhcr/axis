class GoalsStrategyObjectives < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :goal
  belongs_to :strategy_objective
end
