class Operation < ActiveRecord::Base
  self.primary_key = :id

  include SyncableModel
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :id, :name, :years

  serialize :years, Array

  has_many :plans
  has_many :indicator_data
  has_many :budgets
  has_many :expenditures

  has_and_belongs_to_many :indicators, :uniq => true
  has_and_belongs_to_many :outputs, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true
  has_and_belongs_to_many :rights_groups, :uniq => true
  has_and_belongs_to_many :goals, :uniq => true
  has_and_belongs_to_many :ppgs, :uniq => true

  def loaded
    includes([:plan_ids])
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
      json.extract! self, :name, :id, :years
      json.plan_ids self.plan_ids

      json.ppg_ids self.ppg_ids if options[:include][:ppg_ids].present?
      json.goal_ids self.goal_ids if options[:include][:goal_ids].present?
      json.output_ids self.output_ids if options[:include][:output_ids].present?
      if options[:include][:problem_objective_ids].present?
        json.problem_objective_ids self.problem_objective_ids
      end
      json.indicator_ids self.indicator_ids if options[:include][:indicator_ids].present?
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
