class AddStrategyColumns < ActiveRecord::Migration
  def up
    add_column :strategies, :user_id, :integer
    add_column :strategies, :dashboard_type, :string, :default => Strategy::DASHBOARD_TYPES[:global]
    add_column :users, :admin, :boolean, :default => false
  end

  def down
    remove_column :strategies, :user_id, :integer
    remove_column :strategies, :dashboard_type, :string
    remove_column :users, :admin
  end
end
