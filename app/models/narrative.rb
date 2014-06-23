class Narrative < ActiveRecord::Base
  self.primary_key = :id
  include SyncableModel
  attr_accessible :operation_id, :plan_id, :year, :goal_id, :problem_objective_id, :output_id,
    :ppg_id, :elt_id, :plan_el_type, :usertxt, :createusr, :id, :report_type

  belongs_to :operation
  belongs_to :plan
  belongs_to :ppg
  belongs_to :goal
  belongs_to :output
  belongs_to :problem_objective
end
