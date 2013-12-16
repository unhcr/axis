class AddMoreIndexes < ActiveRecord::Migration
  def change
    unless index_exists?(:indicator_data, [:created_at, :updated_at])
      add_index :indicator_data, [:created_at, :updated_at]
    end
    unless index_exists?(:indicator_data, [:created_at])
      add_index :indicator_data, [:created_at]
    end
    unless index_exists?(:indicator_data, [:is_deleted])
      add_index :indicator_data, [:is_deleted]
    end
    unless index_exists?(:budgets, [:created_at, :updated_at])
      add_index :budgets, [:created_at, :updated_at]
    end
    unless index_exists?(:budgets, [:created_at])
      add_index :budgets, [:created_at]
    end
    unless index_exists?(:budgets, [:is_deleted])
      add_index :budgets, [:is_deleted]
    end
  end
end
