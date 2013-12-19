class AddDescriptionToStrategies < ActiveRecord::Migration
  def change
    add_column :strategies, :description, :text
  end
end
