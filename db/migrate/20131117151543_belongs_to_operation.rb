class BelongsToOperation < ActiveRecord::Migration
  def change
    add_column :indicator_data, :operation_id, :string
  end
end
