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
  def synced_data(synced_date = nil, limit = nil, where = {})

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

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :name, :id

      if options[:include] && options[:include][:ids]
        json.indicators_ids self.indicator_ids
        json.goals_ids self.goal_ids
        json.ppgs_ids self.ppg_ids
        json.outputs_ids self.output_ids
        json.plans_ids self.plan_ids
        json.problem_objectives_ids self.problem_objective_ids
      end
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
