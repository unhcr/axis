class AddResetDbToUser < ActiveRecord::Migration
  def change
    add_column :users, :reset_local_db, :boolean, default: false
  end
end
