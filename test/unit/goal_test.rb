require 'test_helper'

class GoalTest < ActiveSupport::TestCase
  def setup
    @goal = goals(:one)
    @goal.operations << operations(:one)
    @goal.ppgs << ppgs(:one)
    @goal.problem_objectives << problem_objectives(:one)
    @goal.save
  end

  test "models" do
    i = [goals(:one), goals(:two)]

    i.map(&:save)

    models = Goal.models

    assert_equal 4, models.count
  end


  test "models with join_ids" do
    i = [goals(:one), goals(:two), goals(:deleted)]
    s = strategies(:one)

    i[1].strategies << s

    i.map(&:save)

    models = Goal.models({ :strategy_id => s.id })

    assert_equal 1, models.count

  end

  test "models with multiple join_ids" do
    i = [goals(:one), goals(:two), goals(:deleted)]
    s = plans(:one)
    s2 = plans(:two)

    i[0].plans << s
    i[1].plans << s2

    i.map(&:save)

    models = Goal.models({ :plan_id => [s.id, s2.id] })

    assert_equal 2, models.count
  end

  test "include options" do
    options = {
      :include => {
        :problem_objective_ids => true,
        :operation_ids => true,
        :ppg_ids => true,
      }
    }

    json = @goal.as_json

    assert_nil json["ppg_ids"]
    assert_nil json["problem_objective_ids"]
    assert_nil json["operation_ids"]

    json = @goal.as_json(options)

    assert_equal json["ppg_ids"].length, 1
    assert_equal json["operation_ids"].length, 1
    assert_equal json["problem_objective_ids"].length, 1
  end
end
