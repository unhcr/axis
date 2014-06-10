require 'test_helper'

class ElementsParserTest < ActiveSupport::TestCase

  COUNTS = {
    :plans => 1,
    :ppgs => 1,
    :goals => 1,
    :rights_groups => 2,
    :problem_objectives => 3,
    :indicators => 50,
    :outputs => 4,
    :operations => 1,
  }

  include Parsers
  def setup
    @parser = Parsers::ElementsParser.new
    # Destory any fixtures or previous data
    Plan.destroy_all
    Ppg.destroy_all
    Goal.destroy_all
    RightsGroup.destroy_all
    ProblemObjective.destroy_all
    Output.destroy_all
    Indicator.destroy_all
    Operation.destroy_all
  end

  test 'Resource to csvfield attrs' do
    attrs = @parser.resource_to_csvfield_attrs Output

    assert attrs
    assert attrs[:id]
    assert attrs[:name]
  end

  test 'Resource to csvfield attrs - indicators' do
    attrs = @parser.resource_to_csvfield_attrs Indicator, Parsers::ElementsParser::PERF_INDICATORS

    assert attrs
    assert attrs[:id]
    assert attrs[:name]
    assert_equal attrs[:name], 'PERFINDICATOR_NAME'

    attrs = @parser.resource_to_csvfield_attrs Indicator, Parsers::ElementsParser::IMPACT_INDICATORS

    assert attrs
    assert attrs[:id]
    assert attrs[:name]
    assert_equal attrs[:name], 'IMPACTINDICATOR_NAME'
  end

  test 'parse' do

    start_time = Time.now
    sleep 1

    @parser.parse "#{Rails.root}/test/files/elements/generated_output.csv"

    assert_equal Operation.count, COUNTS[:operations]
    assert_equal Operation.first.id, '7V5'
    assert_equal Operation.first.years.first, 2013
    assert_equal Operation.first.plans.count, COUNTS[:plans]
    assert Operation.first.name
    assert Operation.first.found_at > start_time


    assert_equal Plan.count, COUNTS[:plans]
    assert_equal Plan.first.id, '86744160-4e90-4c21-a617-87ee9dc4af40'
    assert_equal Plan.first.year, 2013
    assert Plan.first.operation
    assert Plan.first.operation_name

    assert_equal Ppg.count, COUNTS[:ppgs]
    assert_equal Ppg.first.id, 'MAGL'
    assert_equal Ppg.first.name.strip, 'All populations of concern in Africa'

    assert_equal Goal.count, COUNTS[:goals]
    assert_equal Goal.first.id, 'ES'
    assert_equal Goal.first.name.strip, 'Advocacy for protection and solutions'
    assert Goal.first.plans.length > 0
    assert Goal.first.ppgs.length > 0
    assert Goal.first.rights_groups.length > 0
    assert Goal.first.operations.length > 0
    assert Goal.first.problem_objectives.length > 0

    assert_equal RightsGroup.count, COUNTS[:rights_groups]
    RightsGroup.all.each do |rg|
      assert rg.id
      assert rg.name
    end

    assert_equal ProblemObjective.count, COUNTS[:problem_objectives]
    assert_equal ProblemObjective.count, COUNTS[:problem_objectives]
    ProblemObjective.all.each do |po|
      assert po.id
      assert po.problem_name
      assert po.objective_name
    end

    assert_equal Indicator.count, COUNTS[:indicators]
    assert_equal Indicator.where(:is_performance => true).count, 33
    assert_equal Indicator.where(:is_performance => false).count, 17

    assert_equal Output.count, COUNTS[:outputs]
  end

  test 'update' do


    @parser.parse "#{Rails.root}/test/files/elements/generated_output.csv"
    @parser.parse "#{Rails.root}/test/files/elements/generated_output.csv"

    assert_equal Operation.count, COUNTS[:operations]
    assert_equal Operation.first.id, '7V5'
    assert_equal Operation.first.years.first, 2013
    assert_equal Operation.first.plans.count, COUNTS[:plans]


    assert_equal Plan.count, COUNTS[:plans]
    assert_equal Plan.first.id, '86744160-4e90-4c21-a617-87ee9dc4af40'
    assert_equal Plan.first.year, 2013
    assert Plan.first.operation

    assert_equal Ppg.count, COUNTS[:ppgs]
    assert_equal Ppg.first.id, 'MAGL'
    assert_equal Ppg.first.name.strip, 'All populations of concern in Africa'

    assert_equal Goal.count, COUNTS[:goals]
    assert_equal Goal.first.id, 'ES'
    assert_equal Goal.first.name.strip, 'Advocacy for protection and solutions'
    assert Goal.first.plans.length > 0
    assert Goal.first.ppgs.length > 0
    assert Goal.first.rights_groups.length > 0
    assert Goal.first.operations.length > 0
    assert Goal.first.problem_objectives.length > 0

    assert_equal RightsGroup.count, COUNTS[:rights_groups]
    RightsGroup.all.each do |rg|
      assert rg.id
      assert rg.name
    end

    assert_equal ProblemObjective.count, COUNTS[:problem_objectives]
    assert_equal ProblemObjective.count, COUNTS[:problem_objectives]
    ProblemObjective.all.each do |po|
      assert po.id
      assert po.problem_name
      assert po.objective_name
    end

    assert_equal Indicator.count, COUNTS[:indicators]
    assert_equal Indicator.where(:is_performance => true).count, 33
    assert_equal Indicator.where(:is_performance => false).count, 17

    assert_equal Output.count, COUNTS[:outputs]

  end

end

