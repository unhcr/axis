require 'test_helper'

class PlanTest < ActiveSupport::TestCase

  test "get impact indicators" do
    p = plans(:one)
    p.indicators << [indicators(:one), indicators(:two)]
    p.save

    i = p.impact_indicators

    assert_equal 1, i.length
    assert_equal false, i[0].is_performance

  end

end
