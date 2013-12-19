class Strategy < ActiveRecord::Base
  attr_accessible :name, :description

  has_many :strategy_objectives, :before_add => :add_strategy_objective_parameters

  has_and_belongs_to_many :operations, :uniq => true
  has_and_belongs_to_many :plans, :uniq => true
  has_and_belongs_to_many :ppgs, :uniq => true
  has_and_belongs_to_many :goals, :uniq => true, :before_add => :belongs_to_strategy_objective
  has_and_belongs_to_many :rights_groups, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true, :before_add => :belongs_to_strategy_objective
  has_and_belongs_to_many :outputs, :uniq => true, :before_add => :belongs_to_strategy_objective
  has_and_belongs_to_many :indicators, :uniq => true, :before_add => :belongs_to_strategy_objective


  def add_strategy_objective_parameters(strategy_objective)
    self.goals << strategy_objective.goals
    self.problem_objectives << strategy_objective.problem_objectives
    self.outputs << strategy_objective.outputs
    self.indicators << strategy_objective.indicators
  end

  def belongs_to_strategy_objective(assoc)
    raise 'Association does not belong to a Strategy Objective' if assoc.strategy_objectives.empty?
  end

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

  def synced_budgets(synced_date = nil, limit = nil, where = {})
    ids = {
      :plan_ids => self.plan_ids,
      :ppg_ids => self.ppg_ids,
      :goal_ids => self.goal_ids,
      :problem_objective_ids => self.problem_objective_ids,
      :output_ids => self.output_ids,
    }

    return Budget.synced_budgets(ids, synced_date, limit, where)

  end

  def to_jbuilder(options = {})
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :name, :id, :description

      if options[:include][:ids]
        json.indicators_ids self.indicator_ids.inject({}) { |h, id| h[id] = true; h }
        json.goals_ids self.goal_ids.inject({}) { |h, id| h[id] = true; h }
        json.ppgs_ids self.ppg_ids.inject({}) { |h, id| h[id] = true; h }
        json.outputs_ids self.output_ids.inject({}) { |h, id| h[id] = true; h }
        json.plans_ids self.plan_ids.inject({}) { |h, id| h[id] = true; h }
        json.problem_objectives_ids self.problem_objective_ids.inject({}) { |h, id| h[id] = true; h }
      end

      if options[:include][:strategy_objectives]
        json.strategy_objectives self.strategy_objectives
      end
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
