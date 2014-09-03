require 'test_helper'

class AmountTest < ActiveSupport::TestCase

  def setup
    @amounts = [Budget, Expenditure]
  end

  test "models" do
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

      models = resource.models({ :operation_ids => [operations(:one).id] })

      assert_equal 2, models.length, "Should have 2 new #{resource}"
    end

  end

end
