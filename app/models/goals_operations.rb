class GoalsOperations < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :goal
  belongs_to :operation
end

