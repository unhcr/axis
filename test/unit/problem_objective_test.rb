require 'test_helper'

class ProblemObjectiveTest < ActiveSupport::TestCase
  fixtures :all
  def setup

  end

  test "synced models no date" do
    models = ProblemObjective.synced_models

    assert_equal 0, models[:deleted].count
    assert_equal 0, models[:updated].count
    assert_equal 2, models[:new].count
  end

  test "synced model with date" do
    i = [problem_objectives(:one), problem_objectives(:two), problem_objectives(:deleted)]

    # Updated
    i[1].created_at = Time.now - 1.week

    i.map(&:save)

    models = ProblemObjective.synced_models(Time.now - 3.days)

    assert_equal 1, models[:new].count
    assert_equal 1, models[:updated].count
    assert_equal 1, models[:deleted].count

    assert_equal i[0].problem_name, models[:new][0].problem_name
    assert_equal i[1].problem_name, models[:updated][0].problem_name
    assert_equal i[2].problem_name, models[:deleted][0].problem_name
  end

  test "synced models with join_ids" do
    i = [problem_objectives(:one), problem_objectives(:two), problem_objectives(:deleted)]
    s = strategies(:one)

    i[1].strategies << s

    i.map(&:save)

    models = ProblemObjective.synced_models(Time.now - 3.days, { :strategy_id => s.id })

    assert_equal 1, models[:new].count
    assert_equal i[1].problem_name, models[:new][0].problem_name

    i[0].strategies << s
    i[1].created_at = Time.now - 1.week
    i.map(&:save)

    models = ProblemObjective.synced_models(Time.now - 3.days, { :strategy_id => s.id })

    assert_equal 1, models[:new].count
    assert_equal i[0].problem_name, models[:new][0].problem_name
    assert_equal 1, models[:updated].count
    assert_equal i[1].problem_name, models[:updated][0].problem_name
  end

  test "synced models with multiple join_ids" do
    i = [problem_objectives(:one), problem_objectives(:two), problem_objectives(:deleted)]
    s = plans(:one)
    s2 = plans(:two)

    i[0].plans << s
    i[1].plans << s2

    i.map(&:save)

    models = ProblemObjective.synced_models(Time.now - 3.days, { :plan_id => [s.id, s2.id] })

    assert_equal 2, models[:new].count
  end
end
