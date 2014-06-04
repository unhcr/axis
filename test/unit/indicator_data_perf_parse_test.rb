require 'test_helper'

class IndicatorDataPerfParseTest < ActiveSupport::TestCase

  TESTFILE_PATH = "#{Rails.root}/test/files/"

  include Parsers
  include Build
  def setup
    IndicatorDatum.delete_all
    @parser = Parsers::IndicatorDataPerfParser.new
    @path = "#{TESTFILE_PATH}#{Build::IndicatorDataPerfBuild::BUILD_NAME}/#{Build::IndicatorDataPerfBuild::OUTPUT_FILENAME}"

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
      assert b.output_id, 'Must have output id'
      assert b.year, 'Must have year'
      assert (!b.is_performance.nil? && b.is_performance), 'Is not performance indicator'
      assert !b.reversal.nil?, 'Should have reversal'
      assert !!b.reversal == b.reversal, 'Rerversal should be boolean' # Checks that it's a bool
      assert b.priority, 'Should have a priority'
      assert !b.missing_budget.nil?, 'Missing budget'
      assert !b.excluded.nil?, 'Excluded'
      assert b.myr, 'MYR'
      assert b.yer, 'YER'
      assert b.imp_target, 'impact target'
      assert b.comp_target, 'COMP target'
      assert b.indicator_type, 'Indicator Type'
    end
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



