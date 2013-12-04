require 'test_helper'

class AlgorithmHelperTest < ActiveSupport::TestCase

  include AlgorithmHelper

  test "situation analysis" do
    data = [indicator_data(:one), indicator_data(:two)]

    color = situation_analysis_algo(data, 'yer')

    assert_equal color, AlgorithmHelper::ALGO_COLORS[:success]

    color = situation_analysis_algo(data, 'myr')

    assert_equal color, AlgorithmHelper::ALGO_COLORS[:ok]
  end
end
