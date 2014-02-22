class PlansStrategies < ActiveRecord::Base
  belongs_to :plan
  belongs_to :strategy
end

