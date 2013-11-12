class CreateRightsGroups < ActiveRecord::Migration
  def change
    create_table :rights_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
