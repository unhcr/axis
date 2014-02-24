class PlansProblemObjectives < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :problem_objective
  belongs_to :plan
  counter_culture :plan, :column_name => 'custom_problem_objectives_count'
end
