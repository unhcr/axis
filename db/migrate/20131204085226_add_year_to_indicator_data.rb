class AddYearToIndicatorData < ActiveRecord::Migration
  def change
    add_column :indicator_data, :year, :integer
  end
end
