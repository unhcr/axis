class PlansPpgs < ActiveRecord::Base
  belongs_to :ppg
  belongs_to :plan
  counter_culture :plan, :column_name => 'custom_ppgs_count'
end
