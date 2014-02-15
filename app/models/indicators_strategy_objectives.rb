class IndicatorsStrategyObjectives < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :indicator
  belongs_to :strategy_objective
end
