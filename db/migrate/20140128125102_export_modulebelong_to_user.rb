class ExportModulebelongToUser < ActiveRecord::Migration
  def change
    add_column :export_modules, :user_id, :integer

    rename_column :export_modules, :includeExplaination, :include_explaination
    rename_column :export_modules, :includeParameterList, :include_parameter_list

    change_column_default :export_modules, :include_explaination, false
    change_column_default :export_modules, :include_parameter_list, false
  end
end
