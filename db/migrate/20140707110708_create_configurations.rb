class CreateConfigurations < ActiveRecord::Migration
  def change
    create_table :admin_configurations do |t|
      t.integer :startyear, :default => 2012
      t.integer :endyear, :default => 2015
      t.string :default_reported_type, :default => 'yer'
      t.string :default_aggregation_type, :default => 'operations'
      t.integer :default_date, :default => 2013
      t.boolean :default_use_local_storage, :default => true

      t.timestamps
    end
  end
end
