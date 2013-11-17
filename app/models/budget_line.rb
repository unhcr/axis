class BudgetLine < ActiveRecord::Base
  attr_accessible :account_code, :account_name, :amount, :comment, :cost_center, :currency, :implementer_code, :implementer_name, :local_cost, :quantity, :scenerio, :cost_type, :unit, :unit_cost

  self.primary_key = :id
  belongs_to :output
  belongs_to :problem_objective
  belongs_to :rights_group
  belongs_to :goal
  belongs_to :ppg
  belongs_to :plan
end
