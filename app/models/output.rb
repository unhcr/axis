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

  has_many :indicator_data
  has_many :budgets

  has_many :instances


  def to_jbuilder(options = {})
    options ||= {}
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :name, :id
      json.operation_ids self.operation_ids if options[:include][:operation_ids].present?
      if options[:include][:problem_objective_ids].present?
        json.problem_objective_ids self.problem_objective_ids
      end
      json.indicator_ids self.indicator_ids if options[:include][:indicator_ids].present?
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
