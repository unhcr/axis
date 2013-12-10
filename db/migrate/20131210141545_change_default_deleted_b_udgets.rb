class ChangeDefaultDeletedBUdgets < ActiveRecord::Migration
  def change
    change_column_default :budgets, :is_deleted, false
  end
end
