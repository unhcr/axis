require 'test_helper'

class FocusFetchTest < ActiveSupport::TestCase
  fixtures :all
  include FocusFetch
  def setup
  end

  test "Fetching from FOCUS" do
    fetch
  end
end
