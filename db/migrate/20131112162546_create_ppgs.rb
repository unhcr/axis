class CreatePpgs < ActiveRecord::Migration
  def change
    create_table :ppgs do |t|
      t.string :name

      t.timestamps
    end
  end
end
