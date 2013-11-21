class RemoveIndex < ActiveRecord::Migration
  def change
    remove_index :operations, :id
  end
end
