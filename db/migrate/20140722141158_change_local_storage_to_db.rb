class ChangeLocalStorageToDb < ActiveRecord::Migration
  def up
    rename_column :admin_configurations, :default_use_local_storage, :default_use_local_db
  end

  def down
    rename_column :admin_configurations, :default_use_local_db, :default_use_local_storage
  end
end
