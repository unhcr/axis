class RightsGroup < ActiveRecord::Base
  include SyncableModel
  attr_accessible :name

  self.primary_key = :id
  has_many :problem_objectives_rights_groups, :class    => 'ProblemObjectivesRightsGroups'
  has_many :problem_objectives, :uniq => true, :through => :problem_objectives_rights_groups

  has_many :goals_rights_groups, :class     => 'GoalsRightsGroups'
  has_many :goals, :uniq => true, :through => :goals_rights_groups

  has_many :operations_rights_groups, :class    => 'OperationsRightsGroups'
  has_many :operations, :uniq => true, :through => :operations_rights_groups

  has_many :indicator_data
end
