class ExportModule < ActiveRecord::Base
  attr_accessible :data, :description, :include_explaination, :include_parameter_list, :state, :title, :figure_type, :figure_id

  serialize :state, Hash
  serialize :data, Array

  belongs_to :user
end
