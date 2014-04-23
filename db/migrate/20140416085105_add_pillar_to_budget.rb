class AddPillarToBudget < ActiveRecord::Migration
  def change
    add_column :budgets, :pillar, :string
  end
end
