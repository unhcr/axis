class ExportModulesAddColumnFigure < ActiveRecord::Migration
  def change
    add_column :export_modules, :figure_id, :string
    add_column :export_modules, :figure_type, :string
  end
end
