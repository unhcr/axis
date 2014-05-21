class RenameHeadToParent < ActiveRecord::Migration
  def change
    rename_column :positions, :head_position_id, :parent_position_id
    rename_column :offices, :head_office_id, :parent_office_id
  end
end
