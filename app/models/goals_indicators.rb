class GoalsIndicators < ActiveRecord::Base
  belongs_to :indicator
  belongs_to :goal
end



