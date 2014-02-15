class OperationsOutputs < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :output
  belongs_to :operation
end
