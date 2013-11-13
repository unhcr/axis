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

      t.belongs_to :indicator
      t.belongs_to :output
      t.belongs_to :problem_objective
      t.belongs_to :rights_group
      t.belongs_to :goal
      t.belongs_to :ppg
      t.belongs_to :plan

      t.timestamps
    end
  end
end
