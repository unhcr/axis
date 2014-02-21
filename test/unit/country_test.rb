require 'test_helper'

class CountryTest < ActiveSupport::TestCase
  fixtures :all

  include CountryHelper
  test "match plan to country" do
    plan = plans(:one)

    match_model_to_country(plan, plan.operation_name)

    p = Plan.find(plan.id)

    assert p.country
  end

  test "exact match to country" do
    operation = operations(:one)
    match_model_to_country(operation, operation.name)

    o = Operation.find(operation.id)
    assert o.country
    assert_equal 'GOD', o.country.iso3
  end

  test "no match to country" do
    operation = operations(:one)
    match_model_to_country(operation, 'No match please')

    o = Operation.find(operation.id)
    assert_nil o.country
  end
end
