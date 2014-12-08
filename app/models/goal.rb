class Goal < ActiveRecord::Base
  include VisioModel
  include ParameterModel
  include Tire::Model::Search
  include Tire::Model::Callbacks
  attr_accessible :name

  self.primary_key = :id
  has_many :indicator_data
  has_many :budgets
  has_many :expenditures

  has_many :goals_indicators, :class_name => 'GoalsIndicators'
  has_many :indicators, :uniq => true, :through => :goals_indicators

  has_many :goals_outputs, :class_name => 'GoalsOutputs'
  has_many :outputs, :uniq => true, :through => :goals_outputs

  has_many :goals_ppgs, :class_name => 'GoalsPpgs'
  has_many :ppgs, :uniq => true, :through => :goals_ppgs

  has_many :goals_rights_groups, :class_name => 'GoalsRightsGroups'
  has_many :rights_groups, :uniq => true, :through => :goals_rights_groups

  has_many :goals_operations, :class_name => 'GoalsOperations'
  has_many :operations, :uniq => true, :through => :goals_operations

  has_many :goals_strategies, :class_name => 'GoalsStrategies'
  has_many :strategies, :uniq => true, :through => :goals_strategies

  has_many :goals_plans, :class_name => 'GoalsPlans'
  has_many :plans, :uniq => true, :through => :goals_plans

  has_many :goals_problem_objectives, :class_name => 'GoalsProblemObjectives'
  has_many :problem_objectives, :uniq => true, :through => :goals_problem_objectives

  def to_jbuilder(options = {})
    options ||= {}
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :name, :id
      if options[:include][:problem_objective_ids].present?
        json.ppg_ids self.ppg_ids.inject({}) { |h, id| h[id] = true; h }
        json.operation_ids self.operation_ids.inject({}) { |h, id| h[id] = true; h }
        json.problem_objective_ids self.problem_objective_ids.inject({}) { |h, id| h[id] = true; h }
      end
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
