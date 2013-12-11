class Operation < ActiveRecord::Base
  self.primary_key = :id

  include Tire::Model::Search
  include Tire::Model::Callbacks
  extend Searchable

  attr_accessible :id, :name, :years

  serialize :years, Array

  has_many :plans
  has_many :indicator_data

  has_and_belongs_to_many :indicators, :uniq => true
  has_and_belongs_to_many :outputs, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true
  has_and_belongs_to_many :rights_groups, :uniq => true
  has_and_belongs_to_many :goals, :uniq => true
  has_and_belongs_to_many :ppgs, :uniq => true

  def self.public_models(operations, options = {})
    response = Jbuilder.encode do |json|
      json.operations operations do |operation|
        json.(operation, :id, :name, :years)

        json.ppg_ids operation.ppg_ids
        json.goal_ids operation.goal_ids
        json.problem_objective_ids operation.problem_objective_ids
        json.indicator_ids operation.indicator_ids
      end
    end

    return response
  end

end
