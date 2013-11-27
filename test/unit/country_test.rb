require 'test_helper'

class CountryTest < ActiveSupport::TestCase
  fixtures :all

  include CountryHelper
  test "match plan to country" do
    plan = plans(:one)

    match_plan_to_country(plan)

    p = Plan.find(plan.id)

    assert p.country

  end
end
