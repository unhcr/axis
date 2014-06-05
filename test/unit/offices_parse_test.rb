require 'test_helper'

class OfficesParseTest < ActiveSupport::TestCase

  TESTFILE_PATH = "#{Rails.root}/test/files/"

  include Parsers
  include Build
  def setup
    Office.delete_all
    @parser = Parsers::OfficesParser.new
    @path = "#{TESTFILE_PATH}#{Build::OfficesBuild::BUILD_NAME}/#{Build::OfficesBuild::OUTPUT_FILENAME}"

  end

  test "parse small file basic" do

    @parser.parse @path

    assert_equal 50, Office.count, 'Should be 50 offices'

    Office.all.each do |b|
      assert b.operation_id, 'Must have operation'
      assert b.plan_id, 'Must have plan id'
      assert b.name, 'Must have name'
    end

    assert_equal Office.where(:parent_office_id => nil).count, 14
  end

  test "parse small update" do
    @parser.parse @path
    assert_equal 50, Office.count, 'Should be 50 offices'

    found = Time.now

    @parser.parse @path
    assert_equal 50, Office.count, 'Should be 50 datums'
    assert_equal 0, Office.where('found_at < ?', found).length, 'All should have been found the second time'
    assert_equal 0, Office.where('updated_at > ?', found).length, 'None should have been updated the second time'
  end

end





