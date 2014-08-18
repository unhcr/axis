class IndicatorAddRels < ActiveRecord::Migration
  def up
    create_table "indicators_ppgs", :id => false do |t|
      t.column "ppg_id", :string, :null => false
      t.column "indicator_id",  :string, :null => false
    end
    create_table "goals_indicators", :id => false do |t|
      t.column "goal_id", :string, :null => false
      t.column "indicator_id",  :string, :null => false
    end

    add_index :indicators_ppgs, [:ppg_id, :indicator_id], :unique => true, :name => :indicators_ppgs_uniq
    add_index :goals_indicators, [:goal_id, :indicator_id], :unique => true, :name => :goals_indicators_uniq
  end

  def down
    drop_table "indicators_ppgs"
    drop_table "goals_indicators"
  end
end
