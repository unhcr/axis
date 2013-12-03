class AddMyrToIndicatorData < ActiveRecord::Migration
  def change
    add_column :indicator_data, :myr, :integer
  end
end
