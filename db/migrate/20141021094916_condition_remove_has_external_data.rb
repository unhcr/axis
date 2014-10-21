class ConditionRemoveHasExternalData < ActiveRecord::Migration
  def up
    if column_exists? :strategies, :has_external_data
      remove_column :strategies, :has_external_data
    end
  end

  def down
  end
end
