require 'test_helper'

class IndicatorTest < ActiveSupport::TestCase
  def setup
    @i = indicators(:one)
    @i.operations << operations(:one)
    @i.problem_objectives << problem_objectives(:one)
    @i.outputs << outputs(:one)
    @i.save

  end
  test "models no date" do
    models = Indicator.models

    assert_equal 4, models.count
  end


  test "include options" do
    options = {
      :include => {
        :ids => true
      }
    }

    json = @i.as_json

    assert_nil json["problem_objective_ids"]
    assert_nil json["operation_ids"]
    assert_nil json["output_ids"]

    json = @i.as_json(options)

    assert_equal json["problem_objective_ids"].length, 1
    assert_equal json["operation_ids"].length, 1
    assert_equal json["output_ids"].length, 1
  end
end
