class AddIsDeletedToNarratives < ActiveRecord::Migration
  def change
    add_column :narratives, :is_deleted, :boolean, :default => false
  end
end
