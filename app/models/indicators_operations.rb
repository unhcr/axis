class IndicatorsOperations < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :indicator
  belongs_to :operation
end
