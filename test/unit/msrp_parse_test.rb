require 'test_helper'

class MsrpParseTest < ActiveSupport::TestCase

  TESTFILE_PATH = "#{Rails.root}/test/files/"
  include MsrpParse
  def setup
    Expenditure.delete_all

  end

  test "parse small file basic" do

    parse("#{TESTFILE_PATH}#{MsrpFetch::FINAL_FILENAME}")

    assert_equal 10, Expenditure.count, 'Should be 10 expenditure'
  end

end
