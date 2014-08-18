class OutputPoAddRels < ActiveRecord::Migration
  def up
    create_table "outputs_ppgs", :id => false do |t|
      t.column "ppg_id", :string, :null => false
      t.column "output_id",  :string, :null => false
    end
    create_table "goals_outputs", :id => false do |t|
      t.column "goal_id", :string, :null => false
      t.column "output_id",  :string, :null => false
    end
    create_table "ppgs_problem_objectives", :id => false do |t|
      t.column "ppg_id", :string, :null => false
      t.column "problem_objective_id",  :string, :null => false
    end

    add_index :outputs_ppgs, [:ppg_id, :output_id], :unique => true, :name => :outputs_ppgs_uniq
    add_index :goals_outputs, [:goal_id, :output_id], :unique => true, :name => :goals_outputs_uniq
    add_index :ppgs_problem_objectives, [:ppg_id, :problem_objective_id],
        :unique => true, :name => :ppgs_problem_objectives_uniq
  end

  def down
    drop_table "outputs_ppgs"
    drop_table "goals_outputs"
    drop_table "ppgs_problem_objectives"
  end
end
