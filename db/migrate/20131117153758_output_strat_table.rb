class OutputStratTable < ActiveRecord::Migration
  def change
    drop_table :outputs__strategies
    create_table "outputs_strategies", :id => false do |t|
      t.column "strategy_id", :integer, :null => false
      t.column "output_id",  :string, :null => false
    end
  end
end
