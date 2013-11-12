class CreateIndicators < ActiveRecord::Migration
  def change
    create_table :indicators do |t|
      t.string :name
      t.boolean :is_performance
      t.boolean :is_gsp

      t.timestamps
    end
  end
end
