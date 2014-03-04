class AddIndexPlanId < ActiveRecord::Migration
  def up
    add_index :indicator_data, :plan_id
  end

  def down
    remove_index :indicator_data, :plan_id
  end
end
