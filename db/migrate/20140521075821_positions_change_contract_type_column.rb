class PositionsChangeContractTypeColumn < ActiveRecord::Migration
  def up
    rename_column :positions, :contractType, :contract_type
  end

  def down
    rename_column :positions, :contract_type, :contractType
  end
end
