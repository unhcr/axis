class IndicatorsPlans < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :indicator
  belongs_to :plan
  counter_culture :plan, :column_name => 'custom_indicators_count'
end
