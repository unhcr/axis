class PlanIndex < ActiveRecord::Migration
  def change
    add_index(:indicators_plans, [:plan_id, :indicator_id], :unique => true)
  end
end
