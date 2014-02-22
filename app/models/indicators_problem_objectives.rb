class IndicatorsProblemObjectives < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :indicator
  belongs_to :problem_objective
end
