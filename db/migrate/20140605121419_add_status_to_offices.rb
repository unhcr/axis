class AddStatusToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :status, :string
  end
end
