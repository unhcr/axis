class Output < ActiveRecord::Base
  attr_accessible :name, :priority

  self.primary_key = :id
  has_and_belongs_to_many :indicators, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true
  has_and_belongs_to_many :operations, :uniq => true

  has_many :indicator_data
  has_many :budget_lines

  AOL = 'Above Operating Level'
  OL = 'Operating Level'

  def aol_budget
    unless @aol_budget
      aol_budget_lines = self.budget_lines.where(:scenerio => AOL)
      @aol_budget = aol_budget_lines.inject { |b1, b2| b1.amount + b2.amount } || 0
    end
    @aol_budget
  end

  def ol_budget
    unless @ol_budget
      ol_budget_lines = self.budget_lines.where(:scenerio => OL)
      @ol_budget = ol_budget_lines.inject { |b1, b2| b1.amount + b2.amount } || 0
    end
    @ol_budget
  end

  def budget
    return ol_budget + aol_budget
  end
end
