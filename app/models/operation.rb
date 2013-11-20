class Operation < ActiveRecord::Base
  attr_accessible :id, :name, :years

  self.primary_key = :id

  serialize :years, Array

  has_many :plans
  has_many :indicator_data

  has_and_belongs_to_many :indicators
  has_and_belongs_to_many :outputs
  has_and_belongs_to_many :problem_objectives
  has_and_belongs_to_many :rights_groups
  has_and_belongs_to_many :goals
  has_and_belongs_to_many :ppgs

  def self.public_models(operations, options = {})
    response = Jbuilder.encode do |j|
      j.operations operations do |json, operation|
        json.(operation, :id, :name, :years)

        json.ppgs operation.ppgs
        json.goals operation.goals
        json.problem_objectives operation.problem_objectives
        json.indicators operation.indicators
      end
    end

    return response
  end

end
