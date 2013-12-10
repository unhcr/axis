class Output < ActiveRecord::Base
  extend Parameter
  attr_accessible :name, :priority, :ol_admin_budget, :ol_partner_budget, :ol_project_budget, :ol_staff_budget, :aol_admin_budget, :aol_partner_budget, :aol_project_budget, :aol_staff_budget

  self.primary_key = :id
  has_and_belongs_to_many :indicators, :uniq => true
  has_and_belongs_to_many :problem_objectives, :uniq => true
  has_and_belongs_to_many :operations, :uniq => true
  has_and_belongs_to_many :strategies, :uniq => true
  has_and_belongs_to_many :plans, :uniq => true


  has_many :indicator_data
  has_many :budgets


  def budget
    return self.ol_admin_budget + self.ol_staff_budget + self.ol_project_budget + self.ol_partner_budget +
          self.aol_admin_budget + self.aol_staff_budget + self.aol_project_budget + self.aol_partner_budget
  end

  def to_jbuilder(options = {})
    Jbuilder.new do |json|
      json.extract! self, :name, :id, :priority, :ol_admin_budget, :ol_partner_budget, :ol_project_budget, :ol_staff_budget, :aol_admin_budget, :aol_partner_budget, :aol_project_budget, :aol_staff_budget

      json.budget self.budget
    end
  end

  def as_json(options = {})
    to_jbuilder(options).attributes!
  end
end
