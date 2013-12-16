class RemoveByIds < ActiveRecord::Migration
  def change
    remove_index :indicator_data, { name: "by_ids" }
  end
end
