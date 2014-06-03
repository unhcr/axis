class AddOfficePositionRel < ActiveRecord::Migration
  def change
    add_column :positions, :office_id, :string
  end
end
