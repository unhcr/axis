class FetchMonitor < ActiveRecord::Base
  attr_accessible :starttime, :plans

  serialize :plans, Array

  MONITOR_STATES = {
    :incomplete => 'incomplete',
    :complete => 'complete',
    :error => 'error',
    :not_found => 'not found'
  }

  validate do |monitor|
    errors.add(:base, "You can only have one FetchMonitor") unless FetchMonitor.count == 0
  end

  def reset(ids)
    self.mark_deleted

    self.starttime = DateTime.now
    self.plans = ids.map { |id| { :id => id, :state => MONITOR_STATES[:incomplete] } }

    self.save
  end

  def mark_deleted
    return unless self.starttime

    parameters = [Plan, Ppg, Goal, RightsGroup, ProblemObjective, Output, Indicator, IndicatorDatum, Budget]

    parameters.each do |parameter|
      to_delete = parameter.where('found_at < ?', self.starttime).all
      to_undelete = parameter.where('found_at >= ?', self.starttime).all

      to_delete.each do |p|
        p.update_column(:is_deleted, true)
      end
      to_undelete.each do |p|
        p.update_column(:is_deleted, false)
      end
    end
  end

  def reset?
    count = self.plans.count do |plan|
      plan[:state] == MONITOR_STATES[:not_found] || plan[:state] == MONITOR_STATES[:complete]
    end

    count == self.plans.count
  end

  def complete?(id)
    p = plan(id)
    return false unless p

    return p[:state] == MONITOR_STATES[:complete]
  end

  def set_state(id, state)
    p = plan(id)
    p[:state] = state
    self.save
  end

  def plan(id)
    plan = (self.plans.select { |p| p[:id] == id }).first
  end
end
