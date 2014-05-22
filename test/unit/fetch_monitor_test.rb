require 'test_helper'

class FetchMonitorTest < ActiveSupport::TestCase
  test "only one monitor allowed" do
    m = fetch_monitors(:one)
    assert m.save

    m2 = FetchMonitor.new()
    assert !m2.save
  end

  test "reset" do
    plans = [plans(:one), plans(:two)]
    ids = plans.map &:id

    m = fetch_monitors(:one)
    assert_nil m.starttime

    saved = m.reset ids

    assert saved, "Should be allowed to save"

    m.plans.each do |p|
      assert_equal FetchMonitor::MONITOR_STATES[:incomplete], p[:state]
      assert_not_nil p[:id]
      assert !Plan.find(p[:id]).is_deleted
    end

    assert_not_nil m.starttime
  end

  test "reset - should not mark deleted" do
    plans = [plans(:one), plans(:two)]
    ids = plans.map &:id

    m = fetch_monitors(:one)
    assert_nil m.starttime
    m.reset ids

    sleep 1
    Plan.all.each &:found

    m.reset ids

    Plan.all.each do |plan|
      assert !plan.is_deleted
    end
  end

  test "reset - should mark as deleted" do
    plans = [plans(:one), plans(:two)]
    plans.map &:found
    ids = plans.map &:id

    m = fetch_monitors(:one)
    assert_nil m.starttime
    sleep 1
    m.reset ids
    m.reset ids

    Plan.all.each do |plan|
      assert plan.is_deleted
    end
  end

  test "should get plan by id or nil" do
    plans = [plans(:one), plans(:two)]
    ids = plans.map &:id

    m = fetch_monitors(:one)
    m.reset ids
    p = m.plan ids[0]

    assert p
    assert_equal FetchMonitor::MONITOR_STATES[:incomplete], p[:state]
    assert_equal ids[0], p[:id]

    p = m.plan '1238kwq;ijfc82'

    assert_nil p
  end


  test "should test if plan is complete" do
    plans = [plans(:one), plans(:two)]
    ids = plans.map &:id

    m = fetch_monitors(:one)
    m.reset ids
    p = m.plan ids[0]

    assert !m.complete?(p[:id])

    m.set_state(p[:id], FetchMonitor::MONITOR_STATES[:complete])

    assert m.complete?(p[:id])
  end

  test "if monitor should reset" do
    plans = [plans(:one), plans(:two)]
    ids = plans.map &:id

    m = fetch_monitors(:one)
    m.reset ids

    assert !m.reset?

    m.set_state(ids[0], FetchMonitor::MONITOR_STATES[:complete])
    assert !m.reset?

    m.set_state(ids[1], FetchMonitor::MONITOR_STATES[:not_found])
    assert m.reset?

    m.set_state(ids[1], FetchMonitor::MONITOR_STATES[:complete])
    assert m.reset?
  end
end
