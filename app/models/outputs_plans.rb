class OutputsPlans < ActiveRecord::Base
  belongs_to :output
  belongs_to :plan
  counter_culture :plan, :column_name => 'custom_outputs_count'
end
