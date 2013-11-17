require 'test_helper'

class ProblemObjectiveTest < ActiveSupport::TestCase
  fixtures :all
  def setup

    bl = [budget_lines(:one), budget_lines(:two), budget_lines(:three), budget_lines(:four)]
    @po = problem_objectives(:one)
    @po.budget_lines = bl
    @po.save

  end

  test "aol budget calculation" do
    aol_budget = @po.aol_budget

    assert_equal 70, aol_budget, 'Aol Budget'
  end

  test "ol budget calculation" do
    ol_budget = @po.ol_budget

    assert_equal 280, ol_budget, 'Ol Budget'
  end

  test "total budget calculation" do
    budget = @po.budget

    assert_equal 350, budget, 'Budget'
  end

  test "no budget lines test" do

    p = problem_objectives(:two)

    assert_equal 0, p.aol_budget
    assert_equal 0, p.ol_budget
    assert_equal 0, p.budget
  end

end
