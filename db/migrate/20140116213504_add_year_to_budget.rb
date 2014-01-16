class AddYearToBudget < ActiveRecord::Migration
  def change
    add_column :budgets, :year, :integer
  end
end
