class AddIsPerfToIndicatorData < ActiveRecord::Migration
  def change
    add_column :indicator_data, :is_performance, :boolean
  end
end
