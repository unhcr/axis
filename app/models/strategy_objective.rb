class StrategyObjective < ActiveRecord::Base
  attr_accessible :description, :name
  belongs_to :strategy

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
end
