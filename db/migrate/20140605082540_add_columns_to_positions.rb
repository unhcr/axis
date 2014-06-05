class AddColumnsToPositions < ActiveRecord::Migration
  def change
    add_column :positions, :existing, :boolean, :default => true
  end
end
