class CreateFetchMonitors < ActiveRecord::Migration
  def change
    create_table :fetch_monitors do |t|
      t.datetime :starttime
      t.text :plans

      t.timestamps
    end
  end
end
