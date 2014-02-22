class OperationsRightsGroups < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :rights_group
  belongs_to :operation
end
