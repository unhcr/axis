class Operation < ActiveRecord::Base
  attr_accessible :id, :name, :years

  self.primary_key = :id

  serialize :years, Array
end
