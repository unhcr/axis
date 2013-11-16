class Output < ActiveRecord::Base
  attr_accessible :name, :priority

  self.primary_key = :id
  has_and_belongs_to_many :indicators, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true

  has_many :indicator_data
  has_many :budget_lines
end
