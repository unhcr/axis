class AddCountryIdToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :country_id, :integer
  end
end
