class Instance < ActiveRecord::Base
  self.primary_key = :id

  belongs_to :output
end
