class AddUniqueKeyToIndicators < ActiveRecord::Migration
  def up
    add_index :indicators, :id, unique: true
  end
  def down
    remove_index :indicators, :id
  end
end
