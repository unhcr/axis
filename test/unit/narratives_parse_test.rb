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
      assert b.year, 'Must have year'
      assert b.report_type
      assert b.createusr
      assert b.plan_el_type
      assert b.elt_id
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


