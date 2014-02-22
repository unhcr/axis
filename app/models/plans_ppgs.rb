class PlansPpgs < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :ppg
  belongs_to :plan
end
