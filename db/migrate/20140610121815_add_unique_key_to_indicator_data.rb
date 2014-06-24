class AddUniqueKeyToIndicatorData < ActiveRecord::Migration
  def change
    add_index :indicator_data, :id, :unique => true
  end
end
