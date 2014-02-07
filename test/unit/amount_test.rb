require 'test_helper'

class AmountTest < ActiveSupport::TestCase

  def setup
    @amounts = [Budget, Expenditure]
  end

  test "synced_models" do
    @amounts.each do |resource|
      datum = resource.new()
      datum.operation = operations(:one)
      datum.plan = plans(:one)
      datum.ppg = ppgs(:one)
      datum.goal = goals(:one)
      datum.problem_objective = problem_objectives(:one)
      datum.output = outputs(:one)
      datum.save

      datum = resource.new()
      datum.operation = operations(:one)
      datum.save

      models = resource.synced_models({ :operation_ids => [operations(:one).id] })

      assert_equal 2, models[:new].length, "Should have 2 new #{resource}"
      assert_equal 0, models[:updated].length, "Should have 2 new #{resource}"
      assert_equal 0, models[:deleted].length, "Should have 2 new #{resource}"

      models = resource.synced_models({
        :operation_ids => [operations(:one).id],
        :plan_ids => [plans(:one).id],
        :ppg_ids => [ppgs(:one).id],
        :goal_ids => [goals(:one).id],
        :problem_objective_ids => [problem_objectives(:one).id],
        :output_ids => [outputs(:one).id]
      })

      assert_equal 1, models[:new].length, "Should have 1 new #{resource}"
      assert_equal 0, models[:updated].length, "Should have 2 new #{resource}"
      assert_equal 0, models[:deleted].length, "Should have 2 new #{resource}"

      # Irrevalent ids should be ignored
      models = resource.synced_models({
        :operation_ids => [operations(:one).id],
        :plan_ids => [plans(:one).id],
        :ppg_ids => [ppgs(:one).id],
        :goal_ids => [goals(:one).id],
        :problem_objective_ids => [problem_objectives(:one).id],
        :output_ids => [outputs(:one).id],
        :babaganoush_ids => [1],
      })

      assert_equal 1, models[:new].length, "Should have 1 new #{resource}"
      assert_equal 0, models[:updated].length, "Should have 2 new #{resource}"
      assert_equal 0, models[:deleted].length, "Should have 2 new #{resource}"
    end

  end

end
