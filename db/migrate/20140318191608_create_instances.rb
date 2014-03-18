class CreateInstances < ActiveRecord::Migration
  def change
    drop_table :instances
    create_table :instances, :id => false, :force => true do |t|

      t.timestamps
    end

    add_column :instances, :id, :string
  end
end
