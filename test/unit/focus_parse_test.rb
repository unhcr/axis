require 'test_helper'

class FocusParseTest < ActiveSupport::TestCase

  TESTFILE_PATH = "#{Rails.root}/test/files/"
  TESTFILE_NAME = "PlanTest.xml"
  TESTHEADER_NAME = "HeaderTest.xml"
  PLAN_TYPES = ['ONEPLAN']
  include FocusParse
  def setup
    # Destory any fixtures or previous data
    Plan.destroy_all
    Ppg.destroy_all
    Goal.destroy_all
    RightsGroup.destroy_all
    ProblemObjective.destroy_all
    Output.destroy_all
    Indicator.destroy_all
    IndicatorDatum.destroy_all
    BudgetLine.destroy_all
    Operation.destroy_all
  end

  test "Parse operation_header FOCUS" do
    file = File.read(TESTFILE_PATH + TESTHEADER_NAME)
    parse_header(file, PLAN_TYPES)

    assert_equal 139, Operation.count, "Operation count"
    Operation.all.each do |o|
      assert o.years.length >= 0
      assert o.name
      assert o.id
    end
  end

  test "Parse plan FOCUS basic" do
    file = File.read(TESTFILE_PATH + TESTHEADER_NAME)
    parse_header(file, PLAN_TYPES)

    file = File.read(TESTFILE_PATH + TESTFILE_NAME)
    parse_plan(file)

    assert_equal 1, Plan.count, "Plan count"
    Plan.all.each do |plan|
      assert_equal Ppg.count, plan.ppgs.length
    end

    plan = Plan.first
    operation = Operation.where(:name => plan.operation_name).first

    assert_equal 1, operation.plans.length, "Should only have one plan"

    assert_equal 3, Ppg.count, "Ppg count"
    Ppg.all.each do |ppg|
      assert ppg.goals.length >= 0
      assert ppg.goals.length <= Goal.count
    end

    assert_equal 4, Goal.count, "Goal count"
    Goal.all.each do |goal|
      assert goal.rights_groups.length >= 0
      assert goal.rights_groups.length <= RightsGroup.count
    end

    assert_equal 7, RightsGroup.count, "Rights Group count"
    RightsGroup.all.each do |rights_group|
      assert rights_group.problem_objectives.length >= 0
      assert rights_group.problem_objectives.length <= ProblemObjective.count
    end

    assert_equal 17, ProblemObjective.count, "ProblemObjective count"
    ProblemObjective.all.each do |problem_objective|
      assert problem_objective.outputs.length >= 0
      assert problem_objective.outputs.length <= Output.count
      assert problem_objective.indicators.length >= 0
      assert problem_objective.indicators.length <= Indicator.count
    end

    assert_equal 28, Output.count, "Output count"
    Output.all.each do |output|
      assert output.indicators.length >= 0
      assert output.indicators.length <= Indicator.count
    end

    assert_equal 47, Indicator.count, "Indicator count"

    assert_equal 67, IndicatorDatum.count, "IndicatorDatum count"
    IndicatorDatum.all.each do |d|
      assert d.plan, "Must be a plan"
      assert d.ppg, "Must be a ppg"
      assert d.goal, "Must be a goal"
      assert d.rights_group, "Must be a rights group"
      assert d.problem_objective || d.output, "Must be either a obj or output"
      assert d.indicator, "Must be an indicator"
      assert d.operation, "Must be an operation"
    end

    assert_equal 3425, BudgetLine.count, "BudgetLine count"
    BudgetLine.all.each do |d|
      assert d.plan, "Must be a plan"
      assert d.ppg, "Must be a ppg"
      assert d.goal, "Must be a goal"
      assert d.rights_group, "Must be a rights group"
      assert d.problem_objective || d.output, "Must be either a obj or output"
    end
  end

  test "should find duplicates and not create extra entries" do
    file = File.read(TESTFILE_PATH + TESTHEADER_NAME)
    parse_header(file, PLAN_TYPES)

    file = File.read(TESTFILE_PATH + TESTFILE_NAME)
    parse_plan(file)

    file = File.read(TESTFILE_PATH + TESTFILE_NAME)
    parse_plan(file)

    assert_equal 1, Plan.count, "Plan count"
    Plan.all.each do |plan|
      assert_equal Ppg.count, plan.ppgs.length
    end

    plan = Plan.first
    operation = Operation.where(:name => plan.operation_name).first

    assert_equal 1, operation.plans.length, "Should only have one plan"

    assert_equal 3, Ppg.count, "Ppg count"
    Ppg.all.each do |ppg|
      assert ppg.goals.length >= 0
      assert ppg.goals.length <= Goal.count
    end

    assert_equal 4, Goal.count, "Goal count"
    Goal.all.each do |goal|
      assert goal.rights_groups.length >= 0
      assert goal.rights_groups.length <= RightsGroup.count
    end

    assert_equal 7, RightsGroup.count, "Rights Group count"
    RightsGroup.all.each do |rights_group|
      assert rights_group.problem_objectives.length >= 0
      assert rights_group.problem_objectives.length <= ProblemObjective.count
    end

    assert_equal 17, ProblemObjective.count, "ProblemObjective count"
    ProblemObjective.all.each do |problem_objective|
      assert problem_objective.outputs.length >= 0
      assert problem_objective.outputs.length <= Output.count
      assert problem_objective.indicators.length >= 0
      assert problem_objective.indicators.length <= Indicator.count
    end

    assert_equal 28, Output.count, "Output count"
    Output.all.each do |output|
      assert output.indicators.length >= 0
      assert output.indicators.length <= Indicator.count
    end

    assert_equal 47, Indicator.count, "Indicator count"

    assert_equal 67, IndicatorDatum.count, "IndicatorDatum count"
    IndicatorDatum.all.each do |d|
      assert d.plan, "Must be a plan"
      assert d.ppg, "Must be a ppg"
      assert d.goal, "Must be a goal"
      assert d.rights_group, "Must be a rights group"
      assert d.problem_objective || d.output, "Must be either a obj or output"
      assert d.indicator, "Must be an indicator"
      assert d.operation, "Must be an operation"
    end

    assert_equal 3425, BudgetLine.count, "BudgetLine count"
    BudgetLine.all.each do |d|
      assert d.plan, "Must be a plan"
      assert d.ppg, "Must be a ppg"
      assert d.goal, "Must be a goal"
      assert d.rights_group, "Must be a rights group"
      assert d.problem_objective || d.output, "Must be either a obj or output"
    end
  end

  test "Parse operation_header FOCUS duplicates" do
    file = File.read(TESTFILE_PATH + TESTHEADER_NAME)
    parse_header(file, PLAN_TYPES)
    parse_header(file, PLAN_TYPES)

    assert_equal 139, Operation.count, "Operation count"
    Operation.all.each do |o|
      assert o.years.length >= 0
      assert o.name
      assert o.id
    end
  end
end

