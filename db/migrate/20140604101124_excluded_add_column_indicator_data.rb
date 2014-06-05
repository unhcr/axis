class ExcludedAddColumnIndicatorData < ActiveRecord::Migration
  def up
    add_column :indicator_data, :excluded, :boolean, :default => false
  end

  def down
    remove_column :indicator_data, :excluded
  end
end
