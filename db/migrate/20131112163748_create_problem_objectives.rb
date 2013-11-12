class CreateProblemObjectives < ActiveRecord::Migration
  def change
    create_table :problem_objectives do |t|
      t.string :problem_name
      t.string :objective_name
      t.boolean :is_excluded

      t.timestamps
    end
  end
end
