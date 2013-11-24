class RenameTablePlansOutputs < ActiveRecord::Migration
  def change
    rename_table(:plans_outputs, :outputs_plans)
  end
end
