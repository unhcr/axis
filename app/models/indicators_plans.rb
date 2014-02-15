class IndicatorsPlans < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :indicator
  belongs_to :plan
end
