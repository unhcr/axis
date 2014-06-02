require 'test_helper'

class ElementsParseTest < ActiveSupport::TestCase

  include ElementsParse
  def setup
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
    attrs = resource_to_csvfield_attrs Output

    assert attrs
    assert attrs[:id]
    assert attrs[:name]
  end

  test 'Resource to csvfield attrs - indicators' do
    attrs = resource_to_csvfield_attrs Indicator, ElementsParse::PERF_INDICATORS

    assert attrs
    assert attrs[:id]
    assert attrs[:name]
    assert_equal attrs[:name], 'PERFINDICATOR_NAME'

    attrs = resource_to_csvfield_attrs Indicator, ElementsParse::IMPACT_INDICATORS

    assert attrs
    assert attrs[:id]
    assert attrs[:name]
    assert_equal attrs[:name], 'IMPACTINDICATOR_NAME'
  end

  test 'parse' do

    parse "#{Rails.root}/test/files/elements/generated_output.csv"

    assert_equal Operation.count, 1
    assert_equal Operation.first.id, '7V5'
    assert_equal Operation.first.years.first, 2013

    assert_equal Plan.count, 1
    assert_equal Plan.first.id, '86744160-4e90-4c21-a617-87ee9dc4af40'
    assert_equal Plan.first.year, 2013

    assert_equal Ppg.count, 1
    assert_equal Ppg.first.id, 'MAGL'
    assert_equal Ppg.first.name.strip, 'All populations of concern in Africa'

    assert_equal Goal.count, 1
    assert_equal Goal.first.id, 'ES'
    assert_equal Goal.first.name.strip, 'Advocacy for protection and solutions'

    assert_equal RightsGroup.count, 2
    RightsGroup.all.each do |rg|
      assert rg.id
      assert rg.name
    end

    assert_equal ProblemObjective.count, 3
    assert_equal ProblemObjective.count, 3
    ProblemObjective.all.each do |po|
      assert po.id
      assert po.problem_name
      assert po.objective_name
    end

    assert_equal Indicator.where(:is_performance => true).count, 25
    assert_equal Indicator.where(:is_performance => false).count, 22

    assert_equal Output.count, 6
  end

end

