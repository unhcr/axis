class Ppg < ActiveRecord::Base
  include SyncableModel
  include SyncableParameterModel
  include Tire::Model::Search
  include Tire::Model::Callbacks
  attr_accessible :name, :population_type, :population_type_id, :operation_name, :msrp_code

  self.primary_key = :id

  has_many :goals_ppgs, :class_name => 'GoalsPpgs'
  has_many :goals, :uniq => true, :through => :goals_ppgs

  has_many :indicators_ppgs, :class_name => 'IndicatorsPpgs'
  has_many :indicators, :uniq => true, :through => :indicators_ppgs

  has_many :plans_ppgs, :class_name => 'PlansPpgs'
  has_many :plans, :uniq => true, :through => :plans_ppgs

  has_many :operations_ppgs, :class_name => 'OperationsPpgs'
  has_many :operations, :uniq => true, :through => :operations_ppgs

  has_many :ppgs_strategies, :class_name => 'PpgsStrategies'
  has_many :strategies, :uniq => true, :through => :ppgs_strategies

  has_many :outputs_ppgs, :class_name => 'OutputsPpgs'
  has_many :outputs, :uniq => true, :through => :outputs_ppgs

  has_many :ppgs_problem_objectives, :class_name => 'PpgsProblemObjectives'
  has_many :problem_objectives, :uniq => true, :through => :ppgs_problem_objectives

  has_many :indicator_data
  has_many :budgets
  has_many :populations, :conditions => proc { ['populations.year >= ? AND populations.year <= ?',
                                      AdminConfiguration.first.startyear,
                                      AdminConfiguration.first.endyear] }, :foreign_key => :ppg_id

  def to_jbuilder(options = {})
    options ||= {}
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :name, :id, :operation_name
      if options[:include][:ids]
        json.operation_ids self.operation_ids.inject({}) { |h, id| h[id] = true; h }
        json.goal_ids self.goal_ids.inject({}) { |h, id| h[id] = true; h }
      end
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
