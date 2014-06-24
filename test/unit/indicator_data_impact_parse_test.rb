require 'test_helper'

class IndicatorDataImpactParseTest < ActiveSupport::TestCase

  TESTFILE_PATH = "#{Rails.root}/test/files/"

  include Parsers
  include Build
  def setup
    IndicatorDatum.delete_all
    @parser = Parsers::IndicatorDataImpactParser.new
    @path = "#{TESTFILE_PATH}#{Build::IndicatorDataImpactBuild::BUILD_NAME}/#{Build::IndicatorDataImpactBuild::OUTPUT_FILENAME}"

  end

  test "parse small file basic" do

    @parser.parse @path

    assert_equal 50, IndicatorDatum.count, 'Should be 50 datums'

    IndicatorDatum.all.each do |b|
      assert b.plan_id, 'Must have plan'
      assert b.operation_id, 'Must have operation'
      assert b.ppg_id, 'Must have ppg'
      assert b.goal_id, 'Must have goal'
      assert b.problem_objective_id, 'Must have problem objective id'
      assert b.indicator_id, 'Must have indicator id'
      assert b.year, 'Must have year'
      assert (!b.is_performance.nil? && !b.is_performance), 'Is not performance indicator'
      assert !b.reversal.nil?, 'Should have reversal'
      assert b.priority, 'Should have a priority'
      assert !b.missing_budget.nil?, 'Missing budget'
      assert !b.excluded.nil?, 'Excluded'
      assert b.myr.nil?, "MYR: #{b.myr}"
      assert b.yer.nil?, 'YER'
      assert b.standard, 'Standard'
      assert b.threshold_green, 'Threshold green'
      assert b.threshold_red, 'Threshold red'
      assert b.indicator_type, 'Indicator Type'
    end

    assert_equal IndicatorDatum.where(:baseline => nil).count, 1
    assert_equal IndicatorDatum.where(:imp_target => nil).count, 5
  end

  test "parse small update" do
    @parser.parse @path
    assert_equal 50, IndicatorDatum.count, 'Should be 50 datums'

    found = Time.now

    @parser.parse @path
    assert_equal 50, IndicatorDatum.count, 'Should be 50 datums'
    assert_equal 0, IndicatorDatum.where('found_at < ?', found).length, 'All should have been found the second time'
    assert_equal 0, IndicatorDatum.where('updated_at > ?', found).length, 'None should have been updated the second time'
  end

end


