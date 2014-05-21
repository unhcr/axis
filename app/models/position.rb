class Position < ActiveRecord::Base
  self.primary_key = :id
  include SyncableModel
  attr_accessible :contract_type, :fast_track, :grade, :incumbent, :position_reference, :title,
    :head

  has_many :sub_positions, class_name: 'Position',
    foreign_key: 'parent_position_id'

  belongs_to :parent_position, class_name: 'Position'
  belongs_to :operation
  belongs_to :plan
  belongs_to :office

end
