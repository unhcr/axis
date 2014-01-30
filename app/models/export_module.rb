class ExportModule < ActiveRecord::Base
  attr_accessible :figure_config, :description, :include_explaination, :include_parameter_list, :state, :title, :figure_type

  serialize :state, Hash
  serialize :figure_config, Hash

  belongs_to :user
end
