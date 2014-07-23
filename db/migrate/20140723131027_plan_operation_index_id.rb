class PlanOperationIndexId < ActiveRecord::Migration
  def up
    add_index :plans, :operation_id
  end

  def down
    remove_index :plans, :operation_id
  end
end
