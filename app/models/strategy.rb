class Strategy < ActiveRecord::Base
  attr_accessible :name

  has_and_belongs_to_many :operations
  has_and_belongs_to_many :plans
  has_and_belongs_to_many :ppgs
  has_and_belongs_to_many :goals
  has_and_belongs_to_many :rights_groups
  has_and_belongs_to_many :problem_objectives
  has_and_belongs_to_many :outputs
  has_and_belongs_to_many :indicators

  # Get IndicatorData related to particular strategy
  def data

    ids = {
      :operation_ids => self.operation_ids,
      :ppg_ids => self.ppg_ids,
      :goal_ids => self.goal_ids,
      :problem_objective_ids => self.problem_objective_ids,
      :output_ids => self.output_ids,
      :indicator_ids => self.indicator_ids,
    }

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
