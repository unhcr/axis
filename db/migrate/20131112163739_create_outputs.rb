class CreateOutputs < ActiveRecord::Migration
  def change
    create_table :outputs do |t|
      t.string :name
      t.string :priority

      t.timestamps
    end
  end
end
