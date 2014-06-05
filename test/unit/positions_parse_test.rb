require 'test_helper'

class PositionsParseTest < ActiveSupport::TestCase

  TESTFILE_PATH = "#{Rails.root}/test/files/"

  include Parsers
  include Build
  def setup
    Position.delete_all
    @parser = Parsers::PositionsParser.new
    @path = "#{TESTFILE_PATH}#{Build::PositionsBuild::BUILD_NAME}/#{Build::PositionsBuild::OUTPUT_FILENAME}"

  end

  test "parse small file basic" do

    @parser.parse @path

    assert_equal 50, Position.count, 'Should be 50 positions'

    Position.all.each do |b|
      assert b.operation_id, 'Must have operation'
      assert b.plan_id, 'Must have output id'
      assert b.office_id, 'Must have year'
      assert !!b.existing == b.existing, 'Rerversal should be boolean' # Checks that it's a bool
    end

    assert_equal Position.where(:grade => nil).count, 11
    assert_equal Position.where(:incumbent => nil).count, 29
    assert_equal Position.where(:contract_type => nil).count, 14
  end

  test "parse small update" do
    @parser.parse @path
    assert_equal 50, Position.count, 'Should be 50 positions'

    found = Time.now

    @parser.parse @path
    assert_equal 50, Position.count, 'Should be 50 datums'
    assert_equal 0, Position.where('found_at < ?', found).length, 'All should have been found the second time'
    assert_equal 0, Position.where('updated_at > ?', found).length, 'None should have been updated the second time'
  end

end




