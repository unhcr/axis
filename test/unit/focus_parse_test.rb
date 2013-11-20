require 'test_helper'

class FocusParseTest < ActiveSupport::TestCase

  TESTFILE_PATH = "#{Rails.root}/test/files/"
  TESTFILE_NAME = "PlanTest.xml"
  UPDATED_TESTFILE_NAME = "UpdatedPlanTest.xml"
  TESTHEADER_NAME = "HeaderTest.xml"
  PLAN_TYPES = ['ONEPLAN']

  COUNTS = {
    :plans => 1,
    :ppgs => 3,
    :goals => 4,
    :rights_groups => 7,
    :problem_objectives => 17,
    :indicators => 47,
    :outputs => 28,
    :operations => 139,
    :budget_lines => 3425,
    :indicator_data => 67
  }
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

  test "should update plan" do
    file = File.read(TESTFILE_PATH + TESTHEADER_NAME)
    parse_header(file, PLAN_TYPES)

    file = File.read(TESTFILE_PATH + TESTFILE_NAME)
    parse_plan(file)

    updated_file = File.read(TESTFILE_PATH + UPDATED_TESTFILE_NAME)
    parse_plan(updated_file)

    # Ensure counts are the same
    assert_equal COUNTS[:plans], Plan.count, "Plan count"
    assert_equal COUNTS[:ppgs], Ppg.count, "Ppg count"
    assert_equal COUNTS[:goals], Goal.count, "Goal count"
    assert_equal COUNTS[:rights_groups], RightsGroup.count, "Rights Group count"
    assert_equal COUNTS[:problem_objectives], ProblemObjective.count, "ProblemObjective count"
    assert_equal COUNTS[:outputs], Output.count, "Output count"
    assert_equal COUNTS[:operations], Operation.count, "Operation count"
    assert_equal COUNTS[:budget_lines], BudgetLine.count, "BudgetLine count"

    doc = Nokogiri::XML(file) do |config|
      config.noblanks.strict
    end
    updated_doc = Nokogiri::XML(updated_file) do |config|
      config.noblanks.strict
    end

    assert !EquivalentXml.equivalent?(doc, updated_doc, {
      :element_order => false,
      :normalize_whitespace => true })

    assert_equal 2014, Plan.first.year
    assert Goal.where(:name => 'Reintegration Changed').first
    assert RightsGroup.where(:name => 'Basic Needs and Essential Services Changed').first
    assert ProblemObjective.where(:problem_name => 'Health status of the population is unsatisfactory or needs constant attention Changed').first
    assert Output.where(:name => 'Access to primary health care services provided or supported Changed')
    assert BudgetLine.where(:type => 'PROJECT Changed')
    assert Indicator.where(:name => '# of health facilities equipped/constructed/rehabilitated Changed')
  end

  test "Parse operation_header FOCUS" do
    file = File.read(TESTFILE_PATH + TESTHEADER_NAME)
    parse_header(file, PLAN_TYPES)

    assert_equal COUNTS[:operations], Operation.count, "Operation count"
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

    assert_equal COUNTS[:plans], Plan.count, "Plan count"
    Plan.all.each do |plan|
      assert_equal Ppg.count, plan.ppgs.length
    end

    plan = Plan.first
    operation = Operation.where(:name => plan.operation_name).first

    assert_equal COUNTS[:plans], operation.plans.length, "Should only have one plan"

    assert_equal COUNTS[:ppgs], Ppg.count, "Ppg count"
    Ppg.all.each do |ppg|
      assert ppg.goals.length >= 0
      assert ppg.goals.length <= Goal.count
    end

    assert_equal COUNTS[:goals], Goal.count, "Goal count"
    Goal.all.each do |goal|
      assert goal.rights_groups.length >= 0
      assert goal.rights_groups.length <= RightsGroup.count
    end

    assert_equal COUNTS[:rights_groups], RightsGroup.count, "Rights Group count"
    RightsGroup.all.each do |rights_group|
      assert rights_group.problem_objectives.length >= 0
      assert rights_group.problem_objectives.length <= ProblemObjective.count
    end

    assert_equal COUNTS[:problem_objectives], ProblemObjective.count, "ProblemObjective count"
    ProblemObjective.all.each do |problem_objective|
      assert problem_objective.outputs.length >= 0
      assert problem_objective.outputs.length <= Output.count
      assert problem_objective.indicators.length >= 0
      assert problem_objective.indicators.length <= Indicator.count
    end

    assert_equal COUNTS[:outputs], Output.count, "Output count"
    Output.all.each do |output|
      assert output.indicators.length >= 0
      assert output.indicators.length <= Indicator.count
    end

    assert_equal COUNTS[:indicators], Indicator.count, "Indicator count"

    assert_equal COUNTS[:indicator_data], IndicatorDatum.count, "IndicatorDatum count"
    IndicatorDatum.all.each do |d|
      assert d.plan, "Must be a plan"
      assert d.ppg, "Must be a ppg"
      assert d.goal, "Must be a goal"
      assert d.rights_group, "Must be a rights group"
      assert d.problem_objective || d.output, "Must be either a obj or output"
      assert d.indicator, "Must be an indicator"
      assert d.operation, "Must be an operation"
    end

    assert_equal COUNTS[:budget_lines], BudgetLine.count, "BudgetLine count"
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

    assert_equal COUNTS[:plans], Plan.count, "Plan count"
    Plan.all.each do |plan|
      assert_equal Ppg.count, plan.ppgs.length
    end

    plan = Plan.first
    operation = Operation.where(:name => plan.operation_name).first

    assert_equal COUNTS[:plans], operation.plans.length, "Should only have one plan"

    assert_equal COUNTS[:ppgs], Ppg.count, "Ppg count"
    Ppg.all.each do |ppg|
      assert ppg.goals.length >= 0
      assert ppg.goals.length <= Goal.count
    end

    assert_equal COUNTS[:goals], Goal.count, "Goal count"
    Goal.all.each do |goal|
      assert goal.rights_groups.length >= 0
      assert goal.rights_groups.length <= RightsGroup.count
    end

    assert_equal COUNTS[:rights_groups], RightsGroup.count, "Rights Group count"
    RightsGroup.all.each do |rights_group|
      assert rights_group.problem_objectives.length >= 0
      assert rights_group.problem_objectives.length <= ProblemObjective.count
    end

    assert_equal COUNTS[:problem_objectives], ProblemObjective.count, "ProblemObjective count"
    ProblemObjective.all.each do |problem_objective|
      assert problem_objective.outputs.length >= 0
      assert problem_objective.outputs.length <= Output.count
      assert problem_objective.indicators.length >= 0
      assert problem_objective.indicators.length <= Indicator.count
    end

    assert_equal COUNTS[:outputs], Output.count, "Output count"
    Output.all.each do |output|
      assert output.indicators.length >= 0
      assert output.indicators.length <= Indicator.count
    end

    assert_equal COUNTS[:indicators], Indicator.count, "Indicator count"

    assert_equal COUNTS[:indicator_data], IndicatorDatum.count, "IndicatorDatum count"
    IndicatorDatum.all.each do |d|
      assert d.plan, "Must be a plan"
      assert d.ppg, "Must be a ppg"
      assert d.goal, "Must be a goal"
      assert d.rights_group, "Must be a rights group"
      assert d.problem_objective || d.output, "Must be either a obj or output"
      assert d.indicator, "Must be an indicator"
      assert d.operation, "Must be an operation"
    end

    assert_equal COUNTS[:budget_lines], BudgetLine.count, "BudgetLine count"
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

    assert_equal COUNTS[:operations], Operation.count, "Operation count"
    Operation.all.each do |o|
      assert o.years.length >= 0
      assert o.name
      assert o.id
    end
  end
end

