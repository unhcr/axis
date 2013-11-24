require 'test_helper'

class PlanTest < ActiveSupport::TestCase
  test "synced models no date" do
    p = [plans(:one), plans(:two)]

    p.map(&:save)

    models = Plan.synced_models

    assert_equal 0, models[:deleted].count
    assert_equal 0, models[:updated].count
    assert_equal 3, models[:new].count
  end

  test "synced model with date" do
    p = [plans(:one), plans(:two), plans(:deleted)]

    # Updated
    p[1].created_at = Time.now - 1.week

    p.map(&:save)

    models = Plan.synced_models(Time.now - 3.days)

    assert_equal 1, models[:new].count
    assert_equal 1, models[:updated].count
    assert_equal 1, models[:deleted].count

    assert_equal p[0].operation_name, models[:new][0].operation_name
    assert_equal p[1].operation_name, models[:updated][0].operation_name
    assert_equal p[2].operation_name, models[:deleted][0].operation_name
  end
end
