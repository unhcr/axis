class StrategyObjective < ActiveRecord::Base
  attr_accessible :description, :name
  belongs_to :strategy

  default_scope :include => [:goals, :problem_objectives, :outputs, :indicators]

  has_many :goals_strategy_objectives, :class_name => 'GoalsStrategyObjectives'
  has_many :goals, :uniq => true, :through => :goals_strategy_objectives,
    :after_add => :add_to_strategy,
    :after_remove => :remove_from_strategy

  has_many :problem_objectives_strategy_objectives, :class_name => 'ProblemObjectivesStrategyObjectives'
  has_many :problem_objectives, :uniq => true, :through => :problem_objectives_strategy_objectives,
    :after_add => :add_to_strategy,
    :after_remove => :remove_from_strategy

  has_many :outputs_strategy_objectives, :class_name => 'OutputsStrategyObjectives'
  has_many :outputs, :uniq => true, :through => :outputs_strategy_objectives,
    :after_add => :add_to_strategy,
    :after_remove => :remove_from_strategy

  has_many :indicators_strategy_objectives, :class_name => 'IndicatorsStrategyObjectives'
  has_many :indicators, :uniq => true, :through => :indicators_strategy_objectives,
    :after_add => :add_to_strategy,
    :after_remove => :remove_from_strategy

  def add_to_strategy(assoc)
    self.strategy.send(assoc.class.table_name) << assoc if self.strategy
  end

  def remove_from_strategy(assoc)
    self.strategy.send(assoc.class.table_name).delete(assoc) if self.strategy
  end

  def to_jbuilder(options = {})
    options ||= {}
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :name, :id, :description, :strategy_id

      json.goals self.goals
      json.problem_objectives self.problem_objectives
      json.outputs self.outputs
      json.indicators self.indicators

      json.goal_ids self.goal_ids if options[:include][:goal_ids].present?
      json.output_ids self.output_ids if options[:include][:output_ids].present?
      if options[:include][:problem_objective_ids].present?
        json.problem_objective_ids self.problem_objective_ids
      end
      json.indicator_ids self.indicator_ids if options[:include][:indicator_ids].present?
    end
  end

  def to_json(options = {})
    to_jbuilder(options).target!
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
