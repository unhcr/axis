class Manymanyopsprobs < ActiveRecord::Migration
  def change
    drop_table "problem_objectives_operations"

    create_table "operations_problem_objectives", :id => false do |t|
      t.column "problem_objective_id", :string, :null => false
      t.column "operation_id",  :string, :null => false
    end
  end
end
