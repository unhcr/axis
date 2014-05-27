require 'test_helper'

class MsrpParseTest < ActiveSupport::TestCase

  TESTFILE_PATH = "#{Rails.root}/test/files/"

  include MsrpParse
  include Build
  def setup
    Expenditure.delete_all

  end

  test "parse small file basic" do

    parse("#{TESTFILE_PATH}#{Build::MsrpBuild::OUTPUT_FILENAME}")

    assert_equal 10, Expenditure.count, 'Should be 10 expenditure'
    assert_equal 270355, Expenditure.sum(:amount)
  end

  test "parse small update" do
    parse("#{TESTFILE_PATH}#{Build::MsrpBuild::OUTPUT_FILENAME}")
    assert_equal 270355, Expenditure.sum(:amount)

    found = Time.now

    parse("#{TESTFILE_PATH}#{Build::MsrpBuild::OUTPUT_FILENAME}")
    assert_equal 10, Expenditure.count, 'Should be 10 expenditure'
    assert_equal 0, Expenditure.where('found_at < ?', found).length, 'All should have been found the second time'
    assert_equal 0, Expenditure.where('updated_at > ?', found).length, 'None should have been updated the second time'
    assert_equal 270355, Expenditure.sum(:amount)
  end

end
