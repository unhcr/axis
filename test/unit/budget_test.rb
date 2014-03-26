require 'test_helper'

class BudgetTest < ActiveSupport::TestCase
  test "Should be updated if has_many has changed" do
    s = strategies(:one)
    s.save
    b = budgets(:one)
    g = goals(:one)
    b.save
    updated_at = b.updated_at


    sleep 1

    b.goal = g
    b.save
    g.reload
    b.reload

    assert updated_at < b.updated_at, 'Should update after adding relation'

    updated_at = b.updated_at

    sleep 1
    so = strategy_objectives(:one)
    s.strategy_objectives << so
    so.save
    so.goals << g
    g.save
    b.save

    g.reload
    b.reload

    assert updated_at < b.updated_at, 'Should update after its relation has added SO'
  end
end
