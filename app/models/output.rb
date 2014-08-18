class Output < ActiveRecord::Base
  include SyncableModel
  include SyncableParameterModel
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :name
  self.primary_key = :id

  has_many :indicators_outputs, :class_name    => 'IndicatorsOutputs'
  has_many :indicators, :uniq => true, :through => :indicators_outputs

  has_many :outputs_problem_objectives, :class_name    => 'OutputsProblemObjectives'
  has_many :problem_objectives, :uniq => true, :through => :outputs_problem_objectives

  has_many :operations_outputs, :class_name    => 'OperationsOutputs'
  has_many :operations, :uniq => true, :through => :operations_outputs

  has_many :outputs_strategies, :class_name    => 'OutputsStrategies'
  has_many :strategies, :uniq => true, :through => :outputs_strategies

  has_many :outputs_plans, :class_name     => 'OutputsPlans'
  has_many :plans, :uniq => true, :through => :outputs_plans

  has_many :goals_outputs, :class_name => 'GoalsOutputs'
  has_many :goals, :uniq => true, :through => :goals_outputs

  has_many :outputs_ppgs, :class_name => 'OutputsPpgs'
  has_many :ppgs, :uniq => true, :through => :outputs_ppgs

  has_many :indicator_data
  has_many :budgets

  def to_jbuilder(options = {})
    options ||= {}
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :name, :id
      if options[:include][:ids]
        json.ppg_ids self.ppg_ids.inject({}) { |h, id| h[id] = true; h }
        json.operation_ids self.operation_ids.inject({}) { |h, id| h[id] = true; h }
        json.indicator_ids self.indicator_ids.inject({}) { |h, id| h[id] = true; h }
        json.problem_objective_ids self.problem_objective_ids.inject({}) { |h, id| h[id] = true; h }
        json.goal_ids self.goal_ids.inject({}) { |h, id| h[id] = true; h }
      end
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
