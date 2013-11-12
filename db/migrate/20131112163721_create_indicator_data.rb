class CreateIndicatorData < ActiveRecord::Migration
  def change
    create_table :indicator_data do |t|
      t.integer :standard
      t.boolean :reversal
      t.integer :comp_target
      t.integer :yer
      t.integer :baseline
      t.integer :stored_baseline
      t.integer :threshold_green
      t.integer :threshold_red

      t.timestamps
    end
  end
end
