class GoalsPlans < ActiveRecord::Base
  belongs_to :plan
  belongs_to :goal
  counter_culture :plan, :column_name => 'custom_goals_count'
end


