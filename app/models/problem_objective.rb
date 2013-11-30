class ProblemObjective < ActiveRecord::Base
  extend Parameter
  attr_accessible :is_excluded, :objective_name, :problem_name

  self.primary_key = :id
  has_many :indicator_data

  has_and_belongs_to_many :outputs, :uniq => true
  has_and_belongs_to_many :indicators, :uniq => true
  has_and_belongs_to_many :rights_groups, :uniq => true
  has_and_belongs_to_many :operations, :uniq => true
  has_and_belongs_to_many :strategies, :uniq => true
  has_and_belongs_to_many :plans, :uniq => true


  AOL = 'Above Operating Level'
  OL = 'Operating Level'

  def budget
    return self.ol_budget + self.aol_budget
  end

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :objective_name, :problem_name, :id
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
