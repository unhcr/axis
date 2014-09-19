class Indicator < ActiveRecord::Base
  self.primary_key  = :id

  include SyncableModel
  include SyncableParameterModel
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :is_gsp, :is_performance, :name, :indicator_type

  has_many :indicators_outputs, :class_name    => 'IndicatorsOutputs'
  has_many :outputs, :uniq => true, :through => :indicators_outputs

  has_many :indicators_problem_objectives, :class_name     => 'IndicatorsProblemObjectives'
  has_many :problem_objectives, :uniq => true, :through => :indicators_problem_objectives

  has_many :indicators_operations, :class_name     => 'IndicatorsOperations'
  has_many :operations, :uniq => true, :through => :indicators_operations

  has_many :indicators_plans, :class_name    => 'IndicatorsPlans'
  has_many :plans, :uniq => true, :through => :indicators_plans

  has_many :indicators_strategies, :class_name     => 'IndicatorsStrategies'
  has_many :strategies, :uniq => true, :through => :indicators_strategies

  has_many :indicators_ppgs, :class_name => 'IndicatorsPpgs'
  has_many :ppgs, :uniq => true, :through => :indicators_ppgs

  has_many :goals_indicators, :class_name => 'GoalsIndicators'
  has_many :goals, :uniq => true, :through => :goals_indicators

  has_many :indicator_data

  def to_jbuilder(options = {})
    options ||= {}
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :is_gsp, :is_performance, :name, :id, :indicator_type
      if options[:include][:ids]
        json.ppg_ids self.ppg_ids.inject({}) { |h, id| h[id] = true; h }
        json.operation_ids self.operation_ids.inject({}) { |h, id| h[id] = true; h }
        json.output_ids self.output_ids.inject({}) { |h, id| h[id] = true; h }
        json.problem_objective_ids self.problem_objective_ids.inject({}) { |h, id| h[id] = true; h }
        json.goal_ids self.goal_ids.inject({}) { |h, id| h[id] = true; h }
      end
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
