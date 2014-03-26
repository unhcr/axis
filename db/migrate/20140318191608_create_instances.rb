class CreateInstances < ActiveRecord::Migration
  def change
    if table_exists?(:instances)
      drop_table :instances
    end
    create_table :instances, :id => false, :force => true do |t|

      t.timestamps
    end

    add_column :instances, :id, :string
  end
end
