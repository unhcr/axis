class OperationAddColumnCountryId < ActiveRecord::Migration
  def change
    add_column :operations, :country_id, :integer
  end
end
