class AddIsDeletedField < ActiveRecord::Migration
  def change
    add_column :plans, :is_deleted, :boolean, :default => false
    add_column :operations, :is_deleted, :boolean, :default => false
    add_column :ppgs, :is_deleted, :boolean, :default => false
    add_column :goals, :is_deleted, :boolean, :default => false
    add_column :rights_groups, :is_deleted, :boolean, :default => false
    add_column :problem_objectives, :is_deleted, :boolean, :default => false
    add_column :outputs, :is_deleted, :boolean, :default => false
    add_column :indicators, :is_deleted, :boolean, :default => false
    add_column :indicator_data, :is_deleted, :boolean, :default => false
  end
end
