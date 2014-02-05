class ChangeFigureTypeToTest < ActiveRecord::Migration
  def change
    change_column :export_modules, :figure_type, :text
  end
end
