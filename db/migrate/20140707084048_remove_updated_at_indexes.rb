class RemoveUpdatedAtIndexes < ActiveRecord::Migration
  def up
    if index_exists? :expenditures, :updated_at
      remove_index :expenditures, :updated_at
    end
    if index_exists? :budgets, :updated_at
      remove_index :budgets, :updated_at
    end
    if index_exists? :indicator_data, :updated_at
      remove_index :indicator_data, :updated_at
    end
  end

  def down
    add_index :expenditures, :updated_at
    add_index :budgets, :updated_at
    add_index :indicator_data, :updated_at
  end
end
