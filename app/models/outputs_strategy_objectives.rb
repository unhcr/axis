class OutputsStrategyObjectives < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :output
  belongs_to :strategy_objective
end
