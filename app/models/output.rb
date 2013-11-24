class Output < ActiveRecord::Base
  extend Parameter
  attr_accessible :name, :priority

  self.primary_key = :id
  has_and_belongs_to_many :indicators, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true
  has_and_belongs_to_many :operations, :uniq => true

  has_many :indicator_data

  AOL = 'Above Operating Level'
  OL = 'Operating Level'

  def budget
    return self.ol_budget + self.aol_budget
  end
end
