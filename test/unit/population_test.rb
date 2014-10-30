require 'test_helper'

class PopulationTest < ActiveSupport::TestCase
  fixtures :all
  def setup

  end

  test "models optmized" do
    res = Population.models_optimized({ :goal_ids => ['A'] })

    assert_equal JSON.parse(res.values[0][0]).length, 1
    assert_equal JSON.parse(res.values[0][0])[0]['element_id'], 'A'
  end
end

