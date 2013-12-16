class RemoveByIds < ActiveRecord::Migration
  def change
    if index_exists?(:indicator_data, { name: "by_ids" })
      remove_index :indicator_data, { name: "by_ids" }
    end
  end
end
