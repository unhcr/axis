class IndicatorIdIndex < ActiveRecord::Migration
  def up
    add_index :indicator_data, :indicator_id
  end

  def down
    remove_index :indicator_data, :indicator_id
  end
end
