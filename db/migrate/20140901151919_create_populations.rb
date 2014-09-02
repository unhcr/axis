class CreatePopulations < ActiveRecord::Migration
  def up
    create_table :populations, :id => false do |t|
      t.string :ppg_code
      t.string :ppg_id
      t.string :operation_id
      t.integer :year
      t.integer :value
      t.datetime :found_at

      t.timestamps
    end
    add_index(:populations, [:year, :operation_id, :ppg_id], :unique => true, :name => 'populations_uniqueness')
  end

  def down
    drop_table :populations
  end
end
