class ProblemObjective < ActiveRecord::Base
  include SyncableModel
  include SyncableParameterModel
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :is_excluded, :objective_name, :problem_name

  self.primary_key = :id
  has_many :indicator_data
  has_many :budgets

  has_many :outputs_problem_objectives, :class_name => 'OutputsProblemObjectives'
  has_many :outputs, :uniq => true, :through => :outputs_problem_objectives

  has_many :indicators_problem_objectives, :class_name     => 'IndicatorsProblemObjectives'
  has_many :indicators, :uniq => true, :through => :indicators_problem_objectives

  has_many :problem_objectives_rights_groups, :class_name    => 'ProblemObjectivesRightsGroups'
  has_many :rights_groups, :uniq => true, :through => :problem_objectives_rights_groups

  has_many :operations_problem_objectives, :class_name => 'OperationsProblemObjectives'
  has_many :operations, :uniq => true, :through => :operations_problem_objectives

  has_many :problem_objectives_strategies, :class_name     => 'ProblemObjectivesStrategies'
  has_many :strategies, :uniq => true, :through => :problem_objectives_strategies

  has_many :problem_objectives_strategy_objectives, :class_name    => 'ProblemObjectivesStrategyObjectives'
  has_many :strategy_objectives, :uniq => true, :through => :problem_objectives_strategy_objectives

  has_many :plans_problem_objectives, :class_name    => 'PlansProblemObjectives'
  has_many :plans, :uniq => true, :through => :plans_problem_objectives

  has_many :goals_problem_objectives, :class_name => 'GoalsProblemObjectives'
  has_many :goals, :uniq => true, :through => :goals_problem_objectives


  def to_jbuilder(options = {})
    options ||= {}
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :objective_name, :problem_name, :id
      json.operation_ids self.operation_ids if options[:include][:operation_ids].present?
      json.goal_ids self.goal_ids if options[:include][:goal_ids].present?
      json.output_ids self.output_ids if options[:include][:output_ids].present?
      json.indicator_ids self.indicator_ids if options[:include][:indicator_ids].present?
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end

  def self.search_models(query, options = {})
    return [] if !query || query.empty?
    options[:page] ||= 1
    options[:per_page] ||= 6
    s = self.search(options) do
      query { string "objective_name:#{query}" }

      highlight :objective_name
    end
    s
  end
end
