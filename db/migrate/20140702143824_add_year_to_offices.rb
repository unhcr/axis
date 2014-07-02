class AddYearToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :year, :integer
  end
end
