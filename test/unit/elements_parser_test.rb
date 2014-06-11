require 'test_helper'

class ElementsParserTest < ActiveSupport::TestCase

  COUNTS = {
    :plans => 2,
    :ppgs => 3,
    :goals => 4,
    :rights_groups => 8,
    :problem_objectives => 15,
    :indicators => 37,
    :outputs => 21,
    :operations => 2,
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
    assert Operation.first.found_at > start_time
    db_assertions
  end

  test 'update' do


    @parser.parse "#{Rails.root}/test/files/elements/generated_output.csv"
    @parser.parse "#{Rails.root}/test/files/elements/generated_output.csv"

    db_assertions

  end

  def db_assertions
    assert_equal Operation.count, COUNTS[:operations]
    assert Operation.exists? '7V5'
    assert_equal Operation.find('7V5').plans.count, 1
    assert_equal Operation.find('7V5').years.first, 2012
    assert Operation.first.name


    assert_equal Plan.count, COUNTS[:plans]
    assert Plan.exists? '09aa7afb-fe66-47a5-89fc-6d0da4b8b041'
    assert_equal Plan.find('09aa7afb-fe66-47a5-89fc-6d0da4b8b041').year, 2013
    assert Plan.first.operation
    assert Plan.first.operation_name

    assert_equal Ppg.count, COUNTS[:ppgs]
    assert Ppg.exists? 'MAGL'
    assert Ppg.first.name

    assert_equal Goal.count, COUNTS[:goals]
    assert Goal.exists? 'ES'
    assert Goal.first.name
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
    assert_equal Indicator.where(:is_performance => true).count, 22
    assert_equal Indicator.where(:is_performance => false).count, 15

    assert_equal Output.count, COUNTS[:outputs]

  end

end

