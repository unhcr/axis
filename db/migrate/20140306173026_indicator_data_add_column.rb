class IndicatorDataAddColumn < ActiveRecord::Migration
  def change
    add_column :indicator_data, :imp_target, :integer
  end
end
