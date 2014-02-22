class GoalsRightsGroups < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :goal
  belongs_to :rights_group
end
