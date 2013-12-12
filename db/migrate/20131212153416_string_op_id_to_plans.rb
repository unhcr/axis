class StringOpIdToPlans < ActiveRecord::Migration
  def change
    change_column :plans, :operation_id, :string
  end
end
