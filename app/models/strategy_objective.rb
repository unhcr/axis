class StrategyObjective < ActiveRecord::Base
  attr_accessible :description, :name
  belongs_to :strategy

  default_scope :include => [:goals, :problem_objectives, :outputs, :indicators]

  has_and_belongs_to_many :goals, :uniq => true,
    :after_add => :add_to_strategy,
    :after_remove => :remove_from_strategy
  has_and_belongs_to_many :problem_objectives, :uniq => true,
    :after_add => :add_to_strategy,
    :after_remove => :remove_from_strategy
  has_and_belongs_to_many :outputs, :uniq => true,
    :after_add => :add_to_strategy,
    :after_remove => :remove_from_strategy
  has_and_belongs_to_many :indicators, :uniq => true,
    :after_add => :add_to_strategy,
    :after_remove => :remove_from_strategy

  def add_to_strategy(assoc)
    self.strategy.send(assoc.class.table_name) << assoc if self.strategy
  end

  def remove_from_strategy(assoc)
    self.strategy.send(assoc.class.table_name).delete(assoc) if self.strategy
  end

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :name, :id, :description

      json.goals self.goals
      json.problem_objectives self.problem_objectives
      json.outputs self.outputs
      json.indicators self.indicators
    end
  end

  def to_json(options = {})
    to_jbuilder(options).target!
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
