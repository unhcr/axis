require 'test_helper'

class FetchMonitorTest < ActiveSupport::TestCase
  test "only one monitor allowed" do
    m = fetch_monitors(:one)
    assert m.save

    m2 = FetchMonitor.new()
    assert !m2.save
  end

  test "mark_deleted - should not mark deleted" do
    plans = [plans(:one), plans(:two)]
    ids = plans.map &:id

    m = fetch_monitors(:one)
    assert_nil m.starttime
    m.starttime = Time.now

    sleep 1
    Plan.all.each &:found

    m.mark_deleted

    Plan.all.each do |plan|
      assert !plan.is_deleted
    end
  end

  test "mark_deleted - should mark as deleted" do
    plans = [plans(:one), plans(:two)]
    plans.map &:found
    ids = plans.map &:id

    m = fetch_monitors(:one)
    assert_nil m.starttime
    sleep 1
    m.starttime = Time.now
    m.mark_deleted

    Plan.all.each do |plan|
      assert plan.is_deleted
    end
  end

end
