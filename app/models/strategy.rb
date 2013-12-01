class Strategy < ActiveRecord::Base
  attr_accessible :name

  has_and_belongs_to_many :operations, :uniq => true
  has_and_belongs_to_many :plans, :uniq => true
  has_and_belongs_to_many :ppgs, :uniq => true
  has_and_belongs_to_many :goals, :uniq => true
  has_and_belongs_to_many :rights_groups, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true
  has_and_belongs_to_many :outputs, :uniq => true
  has_and_belongs_to_many :indicators, :uniq => true

  # Get IndicatorData related to particular strategy
  def data(synced_date = nil, limit = nil, where = {})

    ids = {
      :plan_ids => self.plan_ids,
      :ppg_ids => self.ppg_ids,
      :goal_ids => self.goal_ids,
      :problem_objective_ids => self.problem_objective_ids,
      :output_ids => self.output_ids,
      :indicator_ids => self.indicator_ids,
    }

    return IndicatorDatum.synced_data(ids, synced_date, limit, where)
  end

end
