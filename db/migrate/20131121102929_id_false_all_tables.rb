class IdFalseAllTables < ActiveRecord::Migration
  def change
    drop_table :ppgs
    drop_table :plans
    drop_table :rights_groups
    drop_table :goals
    drop_table :outputs
    drop_table :indicators
    drop_table :indicator_data
    drop_table :problem_objectives

    create_table :indicators, :id => false do |t|
      t.string :id, :null => false
      t.string :name
      t.boolean :is_performance
      t.boolean :is_gsp

      t.timestamps
    end
    create_table :problem_objectives, :id => false do |t|
      t.string :id, :null => false
      t.string :problem_name
      t.string :objective_name
      t.boolean :is_excluded
      t.integer :aol_budget, :default => 0
      t.integer :ol_budget, :default => 0

      t.timestamps
    end
    create_table :ppgs, :id => false do |t|
      t.string :id, :null => false
      t.string :name

      t.timestamps
    end

    create_table :plans, :id => false do |t|
      t.string :id, :null => false
      t.string :operation
      t.string :name
      t.integer :year

      t.belongs_to :operation

      t.timestamps
    end

    create_table :rights_groups, :id => false do |t|
      t.string :id, :null => false
      t.string :name

      t.timestamps
    end

    create_table :goals, :id => false do |t|
      t.string :id, :null => false
      t.string :name

      t.timestamps
    end

    create_table :outputs, :id => false do |t|
      t.string :id, :null => false
      t.string :name
      t.string :priority
      t.integer :aol_budget, :default => 0
      t.integer :ol_budget, :default => 0

      t.timestamps
    end

    create_table :indicator_data, :id => false do |t|
      t.string :id, :null => false
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
