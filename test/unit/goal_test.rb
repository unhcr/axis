require 'test_helper'

class GoalTest < ActiveSupport::TestCase
  test "synced models no date" do
    i = [goals(:one), goals(:two)]

    i.map(&:save)

    models = Goal.synced_models

    assert_equal 0, models[:deleted].count
    assert_equal 0, models[:updated].count
    assert_equal 3, models[:new].count
  end

  test "synced model with date" do
    i = [goals(:one), goals(:two), goals(:deleted)]

    # Updated
    i[1].created_at = Time.now - 1.week

    i.map(&:save)

    models = Goal.synced_models(Time.now - 3.days)

    assert_equal 1, models[:new].count
    assert_equal 1, models[:updated].count
    assert_equal 1, models[:deleted].count

    assert_equal i[0].name, models[:new][0].name
    assert_equal i[1].name, models[:updated][0].name
    assert_equal i[2].name, models[:deleted][0].name
  end
end
