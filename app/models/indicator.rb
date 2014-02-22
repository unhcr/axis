class Indicator < ActiveRecord::Base
  self.primary_key  = :id

  include SyncableModel
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :is_gsp, :is_performance, :name

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

  has_many :indicators_strategy_objectives, :class_name    => 'IndicatorsStrategyObjectives'
  has_many :strategy_objectives, :uniq => true, :through => :indicators_strategy_objectives


  has_many :indicator_data

  def to_jbuilder(options = {})
    options ||= {}
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :is_gsp, :is_performance, :name, :id
      json.ppg_ids self.ppg_ids if options[:include][:ppg_ids].present?
      json.operation_ids self.operation_ids if options[:include][:operation_ids].present?
      json.output_ids self.output_ids if options[:include][:output_ids].present?
      if options[:include][:problem_objective_ids].present?
        json.problem_objective_ids self.problem_objective_ids
      end
      json.output_ids self.output_ids if options[:include][:output_ids].present?
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
