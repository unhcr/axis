class OutputsProblemObjectives < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :output
  belongs_to :problem_objective
end
