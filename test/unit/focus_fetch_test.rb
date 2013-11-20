require 'test_helper'

class FocusFetchTest < ActiveSupport::TestCase
  fixtures :all
  include FocusFetch
  def setup
  end

  test "Fetching from FOCUS - max files 2" do
    ret = fetch(2)

    assert_equal 2, ret[:files_read]
    assert ret[:files_total] >= 2
  end
end
