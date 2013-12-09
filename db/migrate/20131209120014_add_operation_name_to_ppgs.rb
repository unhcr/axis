class AddOperationNameToPpgs < ActiveRecord::Migration
  def change
    add_column :ppgs, :operation_name, :string
  end
end
