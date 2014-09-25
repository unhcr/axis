class AddUsertxtLengthColumnToNarratives < ActiveRecord::Migration
  def change
    add_column :narratives, :usertxt_length, :integer
  end
end
