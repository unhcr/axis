class StrategyHasExternalData < ActiveRecord::Migration
  def change
    add_column :strategies, :has_external_data, :boolean, { :default => false }
  end
end
