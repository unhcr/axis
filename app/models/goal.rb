class Goal < ActiveRecord::Base
  include SyncableModel
  include Tire::Model::Search
  include Tire::Model::Callbacks
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
    options ||= {}
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :name, :id
      json.ppg_ids self.ppg_ids if options[:include][:ppg_ids].present?
      json.operation_ids self.operation_ids if options[:include][:operation_ids].present?
      if options[:include][:problem_objective_ids].present?
        json.problem_objective_ids self.problem_objective_ids
      end
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
