class AddIndicatorTypeToIndicator < ActiveRecord::Migration
  def change
    add_column :indicators, :indicator_type, :string
  end
end
