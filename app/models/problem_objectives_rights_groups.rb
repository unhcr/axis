class ProblemObjectivesRightsGroups < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :rights_group
  belongs_to :problem_objective
end
