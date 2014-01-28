class ExportModule < ActiveRecord::Base
  attr_accessible :data, :description, :includeExplaination, :includeParameterList, :state, :title

  serialize :state, Hash
  serialize :data, Array

  belongs_to :user
end
