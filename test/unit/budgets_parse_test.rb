require 'test_helper'

class BudgetsParseTest < ActiveSupport::TestCase

  TESTFILE_PATH = "#{Rails.root}/test/files/"

  include Parsers
  include Build
  def setup
    Budget.delete_all
    @parser = Parsers::BudgetParser.new
    @path = "#{TESTFILE_PATH}#{Build::BudgetsBuild::BUILD_NAME}/#{Build::BudgetsBuild::OUTPUT_FILENAME}"

    @sum = 43281278
  end

  test "parse small file basic" do

    @parser.parse @path

    assert_equal 50, Budget.count, 'Should be 50 budgets'
    assert_equal @sum, Budget.sum(:amount)

    Budget.all.each do |b|
      assert b.plan_id, 'Must have plan'
      assert b.operation_id, 'Must have operation'
      assert b.ppg_id, 'Must have ppg'
      assert b.goal_id, 'Must have goal'
      assert b.problem_objective_id, 'Must have problem objective id'
      assert b.output_id, 'Must have output id'
      assert b.year, 'Must have year'
      assert b.scenario, 'Must have scenario'
      assert b.budget_type, 'Must have budget type'
    end

    b = Budget.first

    assert_equal OperationsPpgs.where(:operation_id => b.operation_id, :ppg_id => b.ppg_id).count, 1
    assert_equal GoalsPpgs.where(:goal_id => b.goal_id, :ppg_id => b.ppg_id).count, 1
    assert_equal OutputsProblemObjectives.where(:output_id => b.output_id,
                                                :problem_objective_id => b.problem_objective_id).count, 1
    assert_equal GoalsOutputs.where(:goal_id => b.goal_id, :output_id => b.output_id).count, 1
  end

  test "parse small update" do
    @parser.parse @path
    assert_equal @sum, Budget.sum(:amount)

    found = Time.now

    @parser.parse @path
    assert_equal 50, Budget.count, 'Should be 50 budgets'
    assert_equal 0, Budget.where('found_at < ?', found).length, 'All should have been found the second time'
    assert_equal 0, Budget.where('updated_at > ?', found).length, 'None should have been updated the second time'
    assert_equal @sum, Budget.sum(:amount)

    b = Budget.first

    assert_equal OperationsPpgs.where(:operation_id => b.operation_id, :ppg_id => b.ppg_id).count, 1
    assert_equal GoalsPpgs.where(:goal_id => b.goal_id, :ppg_id => b.ppg_id).count, 1
    assert_equal OutputsProblemObjectives.where(:output_id => b.output_id,
                                                :problem_objective_id => b.problem_objective_id).count, 1
    assert_equal GoalsOutputs.where(:goal_id => b.goal_id, :output_id => b.output_id).count, 1
  end

end

