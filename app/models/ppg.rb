class Ppg < ActiveRecord::Base
  include SyncableModel
  include Tire::Model::Search
  include Tire::Model::Callbacks
  attr_accessible :name, :population_type, :population_type_id, :operation_name

  self.primary_key = :id

  has_many :goals_ppgs, :class_name => 'GoalsPpgs'
  has_many :goals, :uniq => true, :through => :goals_ppgs

  has_many :plans_ppgs, :class_name => 'PlansPpgs'
  has_many :plans, :uniq => true, :through => :plans_ppgs

  has_many :operations_ppgs, :class_name => 'OperationsPpgs'
  has_many :operations, :uniq => true, :through => :operations_ppgs

  has_many :ppgs_strategies, :class_name => 'PpgsStrategies'
  has_many :strategies, :uniq => true, :through => :ppgs_strategies

  has_many :indicator_data
  has_many :budgets

  def to_jbuilder(options = {})
    options ||= {}
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :name, :id, :operation_name
      json.operation_ids self.operation_ids if options[:include][:operation_ids].present?
      json.goal_ids self.goal_ids if options[:include][:goal_ids].present?
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
