class AddColumnPillarToExpenditures < ActiveRecord::Migration
  def change
    add_column :expenditures, :pillar, :string
  end
end
