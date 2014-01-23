class Expenditure < ActiveRecord::Base
  include SyncableModel

  attr_accessible :budget_type, :scenario, :amount, :plan_id, :ppg_id, :goal_id, :output_id,
    :problem_objective_id, :year

  belongs_to :plan
  belongs_to :ppg
  belongs_to :goal
  belongs_to :output
  belongs_to :problem_objective

end
