class Plan < ActiveRecord::Base
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
end
