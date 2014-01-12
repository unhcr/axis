class Goal < ActiveRecord::Base
  extend SyncableModel
  attr_accessible :name

  self.primary_key  = :id
  has_many :indicator_data
  has_many :budgets

  has_and_belongs_to_many :ppgs, :uniq => true
  has_and_belongs_to_many :rights_groups, :uniq => true
  has_and_belongs_to_many :operations, :uniq => true
  has_and_belongs_to_many :strategies, :uniq => true
  has_and_belongs_to_many :strategy_objectives, :uniq => true
  has_and_belongs_to_many :plans, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :name, :id
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
