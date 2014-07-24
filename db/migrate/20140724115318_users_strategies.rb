class UsersStrategies < ActiveRecord::Migration
  def up
    create_table :users_strategies do |t|
      t.belongs_to :user
      t.belongs_to :strategy
      t.integer :permission, :default => 0
      t.timestamps
    end
  end

  def down
    drop_table :users_strategies
  end
end
