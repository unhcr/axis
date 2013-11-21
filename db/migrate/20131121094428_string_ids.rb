class StringIds < ActiveRecord::Migration
  def change
    change_column :rights_groups, :id, :string
    change_column :ppgs, :id, :string
    change_column :plans, :id, :string
    change_column :goals, :id, :string
    change_column :problem_objectives, :id, :string
    change_column :outputs, :id, :string
    change_column :indicators, :id, :string
    change_column :indicator_data, :id, :string
  end
end
