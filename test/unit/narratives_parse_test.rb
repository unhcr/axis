require 'test_helper'

class NarrativesParseTest < ActiveSupport::TestCase

  TESTFILE_PATH = "#{Rails.root}/test/files/"

  include Parsers
  include Build
  def setup
    Narrative.delete_all
    @parser = Parsers::NarrativesParser.new
    @path = "#{TESTFILE_PATH}#{Build::NarrativesBuild::BUILD_NAME}/#{Build::NarrativesBuild::OUTPUT_FILENAME}"

  end

  test "parse small file basic" do

    @parser.parse @path

    assert_equal 50, Narrative.count, 'Should be 50 narratives'

    Narrative.all.each do |b|
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
  end

  test "parse small update" do
    @parser.parse @path

    found = Time.now

    @parser.parse @path
    assert_equal 50, Narrative.count, 'Should be 50 budgets'
    assert_equal 0, Narrative.where('found_at < ?', found).length, 'All should have been found the second time'
    assert_equal 0, Narrative.where('updated_at > ?', found).length, 'None should have been updated the second time'
  end

end


