class OperationsPpgs < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :ppg
  belongs_to :operation
end
