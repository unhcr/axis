class OperationChangeColumns < ActiveRecord::Migration
  def change
    change_column :operations, :id, :string
  end
end
