class ExportModule < ActiveRecord::Migration
  def up
    change_column :export_modules, :state, :longtext
    change_column :export_modules, :figure_config, :longtext
  end

  def down
    change_column :export_modules, :state, :text
    change_column :export_modules, :figure_config, :text
  end
end
