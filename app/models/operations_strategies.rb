class OperationsStrategies < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :operation
  belongs_to :strategy
end
