class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.string :name

      t.timestamps
    end
  end
end
