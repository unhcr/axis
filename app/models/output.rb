class Output < ActiveRecord::Base
  extend Parameter
  attr_accessible :name, :priority, :admin_budget, :partner_budget, :project_budget, :staff_budget, :aol_budget, :ol_budget

  self.primary_key = :id
  has_and_belongs_to_many :indicators, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true
  has_and_belongs_to_many :operations, :uniq => true
  has_and_belongs_to_many :strategies, :uniq => true
  has_and_belongs_to_many :plans, :uniq => true


  has_many :indicator_data


  def budget
    return self.ol_budget + self.aol_budget
  end

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :name, :id, :priority, :ol_budget, :aol_budget, :admin_budget, :partner_budget, :project_budget, :staff_budget
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
