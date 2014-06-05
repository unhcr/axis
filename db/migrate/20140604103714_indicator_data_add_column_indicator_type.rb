class IndicatorDataAddColumnIndicatorType < ActiveRecord::Migration
  def up
    add_column :indicator_data, :indicator_type, :string
  end

  def down
    remove_column :indicator_data, :indicator_type
  end
end
