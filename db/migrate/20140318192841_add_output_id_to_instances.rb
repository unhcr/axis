class AddOutputIdToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :output_id, :string
  end
end
