class PopulationChange < ActiveRecord::Migration
  def up
    rename_column :populations, :operation_id, :element_id
    add_column :populations, :element_type, :string
  end

  def down
    rename_column :populations, :element_id, :operation_id
    remove_column :populations, :element_type
  end
end
