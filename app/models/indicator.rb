class Indicator < ActiveRecord::Base
  self.primary_key  = :id

  include SyncableModel
  include Tire::Model::Search
  include Tire::Model::Callbacks

  attr_accessible :is_gsp, :is_performance, :name

  has_and_belongs_to_many :outputs, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true
  has_and_belongs_to_many :operations, :uniq => true
  has_and_belongs_to_many :plans, :uniq => true
  has_and_belongs_to_many :strategies, :uniq => true
  has_and_belongs_to_many :strategy_objectives, :uniq => true


  has_many :indicator_data

  def to_jbuilder(options = {})
    options ||= {}
    options[:include] ||= {}
    Jbuilder.new do |json|
      json.extract! self, :is_gsp, :is_performance, :name, :id
      json.ppg_ids self.ppg_ids if options[:include][:ppg_ids].present?
      json.operation_ids self.operation_ids if options[:include][:operation_ids].present?
      json.output_ids self.output_ids if options[:include][:output_ids].present?
      if options[:include][:problem_objective_ids].present?
        json.problem_objective_ids self.problem_objective_ids
      end
      json.output_ids self.output_ids if options[:include][:output_ids].present?
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
