class Plan < ActiveRecord::Base
  extend Parameter
  attr_accessible :name, :operation_name, :year

  self.primary_key = :id
  has_and_belongs_to_many :ppgs, :uniq => true
  has_and_belongs_to_many :indicators, :uniq => true
  has_and_belongs_to_many :outputs, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true
  has_and_belongs_to_many :rights_groups, :uniq => true
  has_and_belongs_to_many :goals, :uniq => true

  has_many :indicator_data

  belongs_to :operation

  def self.public_models(plans, options = {})
    response = Jbuilder.encode do |json|
      json.plans plans do |plan|
        json.(plan, :id, :name, :year)

        json.ppg_ids plan.ppg_ids
        json.goal_ids plan.goal_ids
        json.problem_objective_ids plan.problem_objective_ids
        json.indicator_ids plan.indicator_ids
      end
    end

    return response
  end
end
