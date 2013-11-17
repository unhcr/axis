require 'test_helper'

class OutputTest < ActiveSupport::TestCase
  fixtures :all
  def setup

    bl = [budget_lines(:one), budget_lines(:two), budget_lines(:three), budget_lines(:four)]
    @o = outputs(:one)
    @o.budget_lines = bl
    @o.save

  end

  test "aol budget calculation" do
    aol_budget = @o.aol_budget

    assert_equal 70, aol_budget, 'Aol Budget'
  end

  test "ol budget calculation" do
    ol_budget = @o.ol_budget

    assert_equal 280, ol_budget, 'Ol Budget'
  end

  test "total budget calculation" do
    budget = @o.budget

    assert_equal 350, budget, 'Budget'
  end

  test "no budget lines test" do

    o2 = outputs(:two)

    assert_equal 0, o2.aol_budget
    assert_equal 0, o2.ol_budget
    assert_equal 0, o2.budget
  end
end
