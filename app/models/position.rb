class Position < ActiveRecord::Base
  self.primary_key = :id
  include SyncableModel
  attr_accessible :contract_type, :grade, :incumbent, :title, :existing

  scope :head_positions, where(parent_position_id: nil)
  has_many :sub_positions, class_name: 'Position',
    foreign_key: 'parent_position_id'

  belongs_to :parent_position, class_name: 'Position'
  belongs_to :operation
  belongs_to :plan
  belongs_to :office

end
