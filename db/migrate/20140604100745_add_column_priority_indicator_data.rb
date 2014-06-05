class AddColumnPriorityIndicatorData < ActiveRecord::Migration
  def up
    add_column :indicator_data, :priority, :string
  end

  def down
    remove_column :indicator_data, :priority
  end
end
