class StrategiesPlans < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :strategy
  belongs_to :plan
end
