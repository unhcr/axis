class OutputsPlans < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :output
  belongs_to :plan
end
