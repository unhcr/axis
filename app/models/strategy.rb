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

    return IndicatorDatum.relevant_data(ids)
  end

end
