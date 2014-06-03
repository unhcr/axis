class RemoveInstances < ActiveRecord::Migration
  def change
    if table_exists? :instances
      drop_table :instances
    end
  end
end
