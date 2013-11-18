class IndicatorDatum < ActiveRecord::Base
  attr_accessible :baseline, :comp_target, :reversal, :standard, :stored_baseline, :threshold_green, :threshold_red, :yer

  self.primary_key = :id
  belongs_to :indicator
  belongs_to :output
  belongs_to :problem_objective
  belongs_to :rights_group
  belongs_to :goal
  belongs_to :ppg
  belongs_to :plan
  belongs_to :operation

  def self.relevant_data(ids = {})

    data = IndicatorDatum.where('
      operation_id IN (:operation_ids) AND
      ppg_id IN (:ppg_ids) AND
      goal_id IN (:goal_ids) AND
      (problem_objective_id IN (:problem_objective_ids) OR output_id IN (:output_ids)) AND
      indicator_id IN (:indicator_ids)
      ', ids)

    return data

  end
end
