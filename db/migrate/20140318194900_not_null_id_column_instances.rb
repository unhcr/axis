class NotNullIdColumnInstances < ActiveRecord::Migration
  def change
    change_column :instances, :id, :string, { :null => false }
  end
end
