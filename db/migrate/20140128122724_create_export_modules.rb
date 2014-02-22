class CreateExportModules < ActiveRecord::Migration
  def change
    create_table :export_modules do |t|
      t.text :state
      t.string :title
      t.text :description
      t.boolean :includeParameterList
      t.boolean :includeExplaination
      t.text :data

      t.timestamps
    end
  end
end
