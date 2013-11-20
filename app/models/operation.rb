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
end
