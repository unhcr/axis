class OpName < ActiveRecord::Migration
  def change
    rename_column :plans, :operation, :operation_name
  end
end
