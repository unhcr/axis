class StrategyObjective < ActiveRecord::Base
  attr_accessible :description, :name
  belongs_to :strategy

  has_and_belongs_to_many :goals, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true
  has_and_belongs_to_many :outputs, :uniq => true
  has_and_belongs_to_many :indicators, :uniq => true
end
