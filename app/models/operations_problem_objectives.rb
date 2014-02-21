class OperationsProblemObjectives < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :operation
  belongs_to :problem_objective
end
