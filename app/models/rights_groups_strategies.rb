class RightsGroupsStrategies < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :strategy
  belongs_to :rights_group
end

