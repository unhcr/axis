require 'test_helper'

class PpgTest < ActiveSupport::TestCase
  def setup
    @ppg = ppgs(:one)
    @ppg.operations << operations(:one)
    @ppg.goals << goals(:one)
    @ppg.save

  end

  test "synced models with join_ids overlap" do
    i = [ppgs(:one), ppgs(:two), ppgs(:deleted)]
    s = plans(:one)
    s2 = plans(:two)

    i[0].plans << s
    i[0].plans << s2
    i[1].plans << s2

    i.map(&:save)

    models = Ppg.models({ :plan_id => [s.id, s2.id] })

    assert_equal 2, models.count

  end

  test "include options" do
    options = {
      :include => {
        :ids => true,
      }
    }

    json = @ppg.as_json

    assert_nil json["goal_ids"]
    assert_nil json["operation_ids"]

    json = @ppg.as_json(options)

    assert_equal json["goal_ids"].length, 1
    assert_equal json["operation_ids"].length, 1
  end
end
