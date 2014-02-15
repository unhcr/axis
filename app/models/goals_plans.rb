class GoalsPlans < ActiveRecord::Base
  belongs_to :plan
  belongs_to :goal
end


