class RemoveCreatedAtAndUpdatedAtIndex < ActiveRecord::Migration
  def up
    if index_exists? :indicator_data, [:created_at, :updated_at]
      remove_index :indicator_data, [:created_at, :updated_at]
    end
    if index_exists? :budgets, [:created_at, :updated_at]
      remove_index :budgets, [:created_at, :updated_at]
    end
    if index_exists? :expenditures, [:created_at, :updated_at]
      remove_index :expenditures, [:created_at, :updated_at]
    end
  end

  def down
    unless index_exists? :indicator_data, [:created_at, :updated_at]
      add_index :indicator_data, [:created_at, :updated_at]
    end
    unless index_exists? :budgets, [:created_at, :updated_at]
      add_index :budgets, [:created_at, :updated_at]
    end
    unless index_exists? :expenditures, [:created_at, :updated_at]
      add_index :expenditures, [:created_at, :updated_at]
    end
  end
end
