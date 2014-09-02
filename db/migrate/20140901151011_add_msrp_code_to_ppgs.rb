class AddMsrpCodeToPpgs < ActiveRecord::Migration
  def change
    add_column :ppgs, :msrp_code, :string
  end
end
