class ManyToManyStratPlans < ActiveRecord::Migration
  def change
    create_table "plans_strategies", :id => false do |t|
      t.column "strategy_id", :integer, :null => false
      t.column "plan_id",  :string, :null => false
    end
  end
end
