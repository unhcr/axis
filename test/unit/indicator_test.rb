require 'test_helper'

class IndicatorTest < ActiveSupport::TestCase
  def setup
    @i = indicators(:one)
    @i.operations << operations(:one)
    @i.problem_objectives << problem_objectives(:one)
    @i.outputs << outputs(:one)
    @i.save

  end
  test "synced models no date" do
    models = Indicator.synced_models

    assert_equal 0, models[:deleted].count
    assert_equal 0, models[:updated].count
    assert_equal 3, models[:new].count
  end

  test "synced model with date" do
    i = [indicators(:one), indicators(:two), indicators(:deleted)]

    # Updated
    i[1].created_at = Time.now - 1.week

    i.map(&:save)

    models = Indicator.synced_models(Time.now - 3.days)

    assert_equal 2, models[:new].count
    assert_equal 1, models[:updated].count
    assert_equal 1, models[:deleted].count

    assert models[:new].include? i[0]
    assert_equal i[1].name, models[:updated][0].name
    assert_equal i[2].name, models[:deleted][0].name
  end

  test "synced models with join_ids" do
    i = [indicators(:one), indicators(:two), indicators(:deleted)]
    s = strategies(:one)

    i[1].strategies << s

    i.map(&:save)

    models = Indicator.synced_models(Time.now - 3.days, { :strategy_id => s.id })

    assert_equal 1, models[:new].count
    assert_equal i[1].name, models[:new][0].name

    i[0].strategies << s
    i[1].created_at = Time.now - 1.week
    i.map(&:save)

    models = Indicator.synced_models(Time.now - 3.days, { :strategy_id => s.id })

    assert_equal 1, models[:new].count
    assert_equal i[0].name, models[:new][0].name
    assert_equal 1, models[:updated].count
    assert_equal i[1].name, models[:updated][0].name
  end

  test "synced models with multiple join_ids" do
    i = [indicators(:one), indicators(:two), indicators(:deleted)]
    s = plans(:one)
    s2 = plans(:two)

    i[0].plans << s
    i[1].plans << s2

    i.map(&:save)

    models = Indicator.synced_models(Time.now - 3.days, { :plan_id => [s.id, s2.id] })

    assert_equal 2, models[:new].count
  end

  test "include options" do
    options = {
      :include => {
        :ids => true
      }
    }

    json = @i.as_json

    assert_nil json["problem_objective_ids"]
    assert_nil json["operation_ids"]
    assert_nil json["output_ids"]

    json = @i.as_json(options)

    assert_equal json["problem_objective_ids"].length, 1
    assert_equal json["operation_ids"].length, 1
    assert_equal json["output_ids"].length, 1
  end
end
