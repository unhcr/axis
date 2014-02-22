class ExportModuleChangeAttrs < ActiveRecord::Migration
  def change
    rename_column :export_modules, :data, :figure_config
    remove_column :export_modules, :figure_id
  end
end
