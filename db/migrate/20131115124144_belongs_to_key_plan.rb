class BelongsToKeyPlan < ActiveRecord::Migration
  def change
    add_column :plans, :operation_id, :string
  end
end
