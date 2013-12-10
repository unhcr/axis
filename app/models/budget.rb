class Budget < ActiveRecord::Base
  attr_accessible :budget_type, :scenerio, :amount

  belongs_to :plan
  belongs_to :ppg
  belongs_to :goal
  belongs_to :output
  belongs_to :problem_objective
end
