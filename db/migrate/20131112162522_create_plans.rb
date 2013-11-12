class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :operation
      t.string :name
      t.integer :year

      t.timestamps
    end
  end
end
