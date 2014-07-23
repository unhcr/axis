class Operation < ActiveRecord::Base
  self.primary_key = :id

  include SyncableModel
  include SyncableParameterModel
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :id, :name, :years

  has_many :plans
  has_many :indicator_data
  has_many :budgets
  has_many :expenditures
  has_many :offices

  has_many :indicators_operations, :class_name => 'IndicatorsOperations'
  has_many :indicators, :uniq => true, :through => :indicators_operations

  has_many :operations_outputs, :class_name => 'OperationsOutputs'
  has_many :outputs, :uniq => true, :through => :operations_outputs

  has_many :operations_problem_objectives, :class_name => 'OperationsProblemObjectives'
  has_many :problem_objectives, :uniq => true, :through => :operations_problem_objectives

  has_many :operations_rights_groups, :class_name => 'OperationsRightsGroups'
  has_many :rights_groups, :uniq => true, :through => :operations_rights_groups

  has_many :goals_operations, :class_name => 'GoalsOperations'
  has_many :goals, :uniq => true, :through => :goals_operations

  has_many :operations_ppgs, :class_name => 'OperationsPpgs'
  has_many :ppgs, :uniq => true, :through => :operations_ppgs

  belongs_to :country

  default_scope { includes([:country]) }

  def loaded
    includes([:plan_ids])
  end

  def years
    @years ||= self.plans.pluck(:year).uniq
  end

  def to_indexed_json
    Jbuilder.encode do |json|
      json.extract! self, :name, :id
    end
  end

  def to_jbuilder(options = {})
    options ||= {}
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :name, :id
      json.years self.years

      if options[:include][:ids]
        json.indicator_ids self.indicator_ids.inject({}) { |h, id| h[id] = true; h }
        json.goal_ids self.goal_ids.inject({}) { |h, id| h[id] = true; h }
        json.ppg_ids self.ppg_ids.inject({}) { |h, id| h[id] = true; h }
        json.output_ids self.output_ids.inject({}) { |h, id| h[id] = true; h }
        json.plan_ids self.plan_ids.inject({}) { |h, id| h[id] = true; h }
        json.problem_objective_ids self.problem_objective_ids.inject({}) { |h, id| h[id] = true; h }
      end
      json.country self.country
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
