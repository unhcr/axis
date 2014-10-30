class Expenditure < ActiveRecord::Base
  include SyncableModel
  extend AmountHelpers

  attr_accessible :budget_type, :scenario, :amount, :plan_id, :ppg_id, :goal_id, :output_id,
    :problem_objective_id, :year, :operation_id, :is_deleted, :pillar

  belongs_to :operation
  belongs_to :plan
  belongs_to :ppg
  belongs_to :goal
  belongs_to :output
  belongs_to :problem_objective

  def self.loaded
    includes({ :goal => :strategy_objectives,
               :problem_objective => :strategy_objectives,
               :output => :strategy_objectives})
  end

  def self.public_fields
    %w{id budget_type scenario amount ppg_id goal_id output_id problem_objective_id operation_id pillar year}
  end

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :id, :budget_type, :scenario, :amount, :plan_id, :ppg_id, :goal_id, :output_id,
        :problem_objective_id, :year, :operation_id, :pillar

      strategy_objective_ids = self.goal.strategy_objective_ids &
        self.problem_objective.strategy_objective_ids

      strategy_objective_ids &= self.output.strategy_objective_ids if self.output

      json.strategy_objective_ids strategy_objective_ids
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
