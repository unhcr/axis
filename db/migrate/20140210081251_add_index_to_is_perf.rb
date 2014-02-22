class AddIndexToIsPerf < ActiveRecord::Migration
  def up
    add_index :indicator_data, :is_performance
  end
  def down
    remove_index :indicator_data, :is_performance
  end
end
